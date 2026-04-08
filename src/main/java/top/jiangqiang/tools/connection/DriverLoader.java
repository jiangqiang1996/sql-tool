package top.jiangqiang.tools.connection;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.lang.reflect.Method;
import java.net.URL;
import java.net.URLClassLoader;
import java.sql.Driver;
import java.sql.SQLException;
import java.sql.SQLFeatureNotSupportedException;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;

/**
 * 从指定目录动态加载 JDBC 驱动。
 * 优先通过 SPI 配置文件 (META-INF/services/java.sql.Driver) 发现驱动类，
 * 仅在 SPI 不可用时才回退到全量 class 扫描。
 */
public class DriverLoader {

    private static final String DRIVER_SPI_PATH = "META-INF/services/java.sql.Driver";

    private final String driversDir;

    public DriverLoader(String driversDir) {
        this.driversDir = driversDir;
    }

    public void loadDrivers() throws IOException {
        File dir = new File(driversDir);
        if (!dir.exists()) {
            System.err.printf("Warning: Drivers directory '%s' does not exist%n", driversDir);
            return;
        }

        File[] jarFiles = dir.listFiles((d, name) -> name.toLowerCase().endsWith(".jar"));
        if (jarFiles == null || jarFiles.length == 0) {
            System.err.printf("Warning: No JAR files found in '%s'%n", driversDir);
            return;
        }

        System.out.printf("Loading %d driver(s) from %s...%n", jarFiles.length, driversDir);

        List<URL> jarUrls = new ArrayList<>();
        for (File jarFile : jarFiles) {
            try {
                jarUrls.add(jarFile.toURI().toURL());
                System.out.printf("  Loading: %s%n", jarFile.getName());
            } catch (Exception e) {
                System.err.printf("  Failed to read: %s - %s%n", jarFile.getName(), e.getMessage());
            }
        }

        ClassLoader currentClassLoader = Thread.currentThread().getContextClassLoader();
        URLClassLoader driverClassLoader = new URLClassLoader(jarUrls.toArray(new URL[0]), currentClassLoader);
        Thread.currentThread().setContextClassLoader(driverClassLoader);

        int loadedCount = 0;
        for (File jarFile : jarFiles) {
            try {
                loadedCount += loadDriversFromJar(jarFile, driverClassLoader);
            } catch (Exception e) {
                System.err.printf("  Failed to scan %s: %s%n", jarFile.getName(), e.getMessage());
            }
        }

        System.out.printf("Loaded %d driver(s) successfully%n", loadedCount);
    }

    /**
     * 优先通过 SPI 配置发现驱动类；若无 SPI 则回退到全量 class 扫描。
     */
    private int loadDriversFromJar(File jarFile, URLClassLoader classLoader) throws IOException {
        int found = 0;

        // 优先读取 SPI 配置
        List<String> driverClasses = readSpiDriverClasses(jarFile);

        if (!driverClasses.isEmpty()) {
            for (String className : driverClasses) {
                found += tryRegisterDriver(className, classLoader);
            }
        } else {
            // 回退：全量扫描 class 文件
            found += scanAllClassesForDrivers(jarFile, classLoader);
        }

        return found;
    }

    /**
     * 读取 JAR 中的 META-INF/services/java.sql.Driver SPI 配置。
     */
    private List<String> readSpiDriverClasses(File jarFile) throws IOException {
        List<String> classes = new ArrayList<>();
        try (JarFile jar = new JarFile(jarFile)) {
            JarEntry spiEntry = jar.getJarEntry(DRIVER_SPI_PATH);
            if (spiEntry == null) {
                return classes;
            }
            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(jar.getInputStream(spiEntry)))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    line = line.trim();
                    if (!line.isEmpty() && !line.startsWith("#")) {
                        classes.add(line);
                    }
                }
            }
        }
        return classes;
    }

    /**
     * 尝试加载并注册指定的驱动类。
     */
    private int tryRegisterDriver(String className, URLClassLoader classLoader) {
        try {
            Class<?> clazz = classLoader.loadClass(className);
            if (Driver.class.isAssignableFrom(clazz) && !clazz.isInterface()) {
                Driver driver = (Driver) clazz.getDeclaredConstructor().newInstance();
                java.sql.DriverManager.registerDriver(new DriverShim(driver));
                System.out.printf("    Registered driver: %s (%s)%n", driver.getClass().getSimpleName(), className);
                return 1;
            }
        } catch (ClassNotFoundException | NoClassDefFoundError ignored) {
            // 驱动类依赖缺失，跳过
        } catch (Exception e) {
            System.err.printf("    Failed to load %s: %s%n", className, e.getMessage());
        }
        return 0;
    }

    /**
     * 回退方案：遍历 JAR 中所有 .class 文件，通过反射检测 Driver 实现。
     */
    private int scanAllClassesForDrivers(File jarFile, URLClassLoader classLoader) throws IOException {
        int found = 0;
        try (JarFile jar = new JarFile(jarFile)) {
            Enumeration<JarEntry> entries = jar.entries();
            while (entries.hasMoreElements()) {
                JarEntry entry = entries.nextElement();
                String name = entry.getName();
                if (!name.endsWith(".class")) continue;

                String className = name.replace('/', '.').substring(0, name.length() - 6);
                found += tryRegisterDriver(className, classLoader);
            }
        }
        return found;
    }

    /**
     * Wrapper to make the dynamically loaded driver compatible with DriverManager
     */
    private static class DriverShim implements java.sql.Driver {
        private final Driver delegate;

        public DriverShim(Driver delegate) {
            this.delegate = delegate;
        }

        @Override
        public boolean acceptsURL(String url) throws SQLException {
            return delegate.acceptsURL(url);
        }

        @Override
        public java.sql.DriverPropertyInfo[] getPropertyInfo(String url, java.util.Properties info) throws SQLException {
            return delegate.getPropertyInfo(url, info);
        }

        @Override
        public int getMajorVersion() {
            return delegate.getMajorVersion();
        }

        @Override
        public int getMinorVersion() {
            return delegate.getMinorVersion();
        }

        @Override
        public boolean jdbcCompliant() {
            return delegate.jdbcCompliant();
        }

        @Override
        public java.util.logging.Logger getParentLogger() throws SQLFeatureNotSupportedException {
            try {
                Method method = delegate.getClass().getMethod("getParentLogger");
                return (java.util.logging.Logger) method.invoke(delegate);
            } catch (Exception e) {
                throw new SQLFeatureNotSupportedException();
            }
        }

        @Override
        public java.sql.Connection connect(String url, java.util.Properties info) throws SQLException {
            return delegate.connect(url, info);
        }
    }
}