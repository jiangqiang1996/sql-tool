import { tool } from "@opencode-ai/plugin"
import path from "path"
import { existsSync, readdirSync } from "fs"

const TOOL_DIR = ".opencode/tools/sql-tool"
const JAR_NAME = "sql-tool.jar"
const EXE_NAME = "sql-tool.exe"
const DRIVERS_DIR = "drivers"

export default tool({
  description:
    "通过 JDBC 连接执行 SQL 查询，支持任意数据库操作。" +
    "支持 SELECT、INSERT、UPDATE、DELETE、DDL 及所有数据库管理操作。" +
    "查询结果以 ASCII 表格返回，便于解析。" +
    "支持 MySQL、PostgreSQL、SQL Server、Oracle、SQLite 及任何提供 JDBC 驱动的数据库。" +
    "⚠️ 首次连接某种数据库前，必须先在 .opencode/tools/sql-tool/drivers/ 目录下放入对应的 JDBC 驱动 JAR 包。",
  args: {
    url: tool.schema
      .string()
      .describe(
        "JDBC 连接地址。示例：jdbc:mysql://localhost:3306/dbname、" +
        "jdbc:postgresql://localhost:5432/dbname、jdbc:sqlserver://localhost:1433;databaseName=dbname、" +
        "jdbc:oracle:thin:@localhost:1521:ORCL、jdbc:sqlite:file.db"
      ),
    username: tool.schema
      .string()
      .optional()
      .describe("数据库用户名（SQLite 不需要）"),
    password: tool.schema
      .string()
      .optional()
      .describe("数据库密码（SQLite 不需要）"),
    sql: tool.schema
      .string()
      .describe(
        "要执行的 SQL 语句。可以是任何合法的 SQL：SELECT、INSERT、UPDATE、DELETE、CREATE、ALTER、DROP 等。"
      ),
  },
  async execute(args, context) {
    const toolDir = path.join(context.worktree, TOOL_DIR)
    const jarPath = path.join(toolDir, JAR_NAME)
    const exePath = path.join(toolDir, EXE_NAME)
    const driversDir = path.join(toolDir, DRIVERS_DIR)

    // 检查驱动目录
    if (!existsSync(driversDir)) {
      return (
        `错误：驱动目录不存在。\n` +
        `期望路径：${driversDir}\n\n` +
        `请创建该目录并放入对应的 JDBC 驱动 JAR 包。`
      )
    }

    const files = readdirSync(driversDir)
    const jarFiles = files.filter((f) => f.toLowerCase().endsWith(".jar"))
    if (jarFiles.length === 0) {
      return (
        `错误：驱动目录为空，没有找到任何 JDBC 驱动 JAR 包。\n` +
        `目录：${driversDir}\n\n` +
        `请根据需要连接的数据库类型，将对应的驱动 JAR 文件放入该目录。`
      )
    }

    // 构建命令：优先使用 java -jar（UTF-8 输出可靠），回退到 exe
    let cmdParts: string[]
    if (existsSync(jarPath)) {
      cmdParts = ["java", "-Dfile.encoding=UTF-8", "-jar", jarPath, "--url", args.url, "--drivers-dir", driversDir]
    } else if (existsSync(exePath)) {
      cmdParts = [exePath, "--url", args.url, "--drivers-dir", driversDir]
    } else {
      return (
        `错误：sql-tool 未找到。\n` +
        `期望路径（任一）：\n` +
        `  ${jarPath}\n` +
        `  ${exePath}\n\n` +
        `请先构建项目或将编译产物复制到 ${TOOL_DIR}/ 目录。`
      )
    }

    if (args.username) cmdParts.push("--username", args.username)
    if (args.password) cmdParts.push("--password", args.password)
    cmdParts.push("--sql", args.sql)

    try {
      const proc = Bun.spawn(cmdParts, {
        stdout: "pipe",
        stderr: "pipe",
      })

      const [stdout, stderr] = await Promise.all([
        new Response(proc.stdout).text(),
        new Response(proc.stderr).text(),
      ])

      const exitCode = await proc.exited

      if (exitCode !== 0) {
        // 提取关键错误信息，忽略 Java 堆栈跟踪
        const errorLines = stderr
          .split("\n")
          .filter(
            (line) =>
              line.startsWith("Error:") ||
              line.startsWith("Warning:") ||
              line.startsWith("Loading")
          )
          .join("\n")
        const errorMsg = errorLines || stderr
        return `执行失败：\n${errorMsg}`
      }

      return stdout
    } catch (err) {
      return `调用 sql-tool 失败：${err instanceof Error ? err.message : String(err)}`
    }
  },
})
