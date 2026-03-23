package top.jiangqiang.tools.connection;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.Method;
import java.net.URL;
import java.net.URLClassLoader;
import java.sql.Driver;
import java.sql.SQLException;
import java.sql.SQLFeatureNotSupportedException;
import java.util.Enumeration;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;

/**
 * Dynamically loads JDBC drivers from the specified drivers directory
 */
public class DriverLoader {

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

        File[] jarFiles = dir.listFiles((dir1, name) -> name.toLowerCase().endsWith(".jar"));
        if (jarFiles == null || jarFiles.length == 0) {
            System.err.printf("Warning: No JAR files found in '%s'%n", driversDir);
            return;
        }

        System.out.printf("Loading %d driver(s) from %s...%n", jarFiles.length, driversDir);

        URL[] jarUrls = new URL[jarFiles.length];
        for (int i = 0; i < jarFiles.length; i++) {
            try {
                jarUrls[i] = jarFiles[i].toURI().toURL();
                System.out.printf("  Loading: %s%n", jarFiles[i].getName());
            } catch (Exception e) {
                System.err.printf("  Failed to read: %s - %s%n", jarFiles[i].getName(), e.getMessage());
            }
        }

        // Create a class loader for the driver JARs
        ClassLoader currentClassLoader = Thread.currentThread().getContextClassLoader();
        URLClassLoader driverClassLoader = new URLClassLoader(jarUrls, currentClassLoader);
        Thread.currentThread().setContextClassLoader(driverClassLoader);

        // Scan JARs for Driver classes
        int loadedCount = 0;
        for (File jarFile : jarFiles) {
            try {
                loadedCount += scanJarForDrivers(jarFile, driverClassLoader);
            } catch (Exception e) {
                System.err.printf("  Failed to scan %s: %s%n", jarFile.getName(), e.getMessage());
            }
        }

        System.out.printf("Loaded %d driver(s) successfully%n", loadedCount);
    }

    private int scanJarForDrivers(File jarFile, URLClassLoader classLoader) throws IOException {
        int found = 0;
        JarFile jar = new JarFile(jarFile);
        Enumeration<JarEntry> entries = jar.entries();

        while (entries.hasMoreElements()) {
            JarEntry entry = entries.nextElement();
            String name = entry.getName();

            if (name.endsWith(".class")) {
                String className = name.replace('/', '.').substring(0, name.length() - 6);

                try {
                    Class<?> clazz = classLoader.loadClass(className);
                    if (Driver.class.isAssignableFrom(clazz) && !clazz.isInterface()) {
                        // Register the driver
                        Driver driver = (Driver) clazz.getDeclaredConstructor().newInstance();
                        java.sql.DriverManager.registerDriver(new DriverShim(driver));
                        System.out.printf("    Found driver: %s (%s)%n", driver.getClass().getSimpleName(), className);
                        found++;
                    }
                } catch (ClassNotFoundException | NoClassDefFoundError ignored) {
                    // Skip classes with missing dependencies
                } catch (Exception e) {
                    System.err.printf("    Failed to load %s: %s%n", className, e.getMessage());
                }
            }
        }

        jar.close();
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