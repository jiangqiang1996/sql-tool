package top.jiangqiang.tools.formatting;

import java.io.PrintStream;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * 将 ResultSet 格式化为 ASCII 表格输出。
 */
public class ResultFormatter {

    private static final String BORDER_CHAR = "-";
    private static final String PIPE_CHAR = "|";
    private static final String CROSS_CHAR = "+";

    /**
     * 将 ResultSet 格式化为 ASCII 表格并输出到指定 PrintStream。
     * 输出完毕后 ResultSet 的游标已遍历到底部。
     */
    public void format(ResultSet resultSet, PrintStream out) throws SQLException {
        ResultSetMetaData metaData = resultSet.getMetaData();
        int columnCount = metaData.getColumnCount();

        // Get column names and calculate widths
        List<String> columnNames = new ArrayList<>();
        List<Integer> columnWidths = new ArrayList<>();

        for (int i = 1; i <= columnCount; i++) {
            String columnName = metaData.getColumnLabel(i);
            if (columnName == null || columnName.isEmpty()) {
                columnName = metaData.getColumnName(i);
            }
            columnNames.add(columnName);
            columnWidths.add(columnName.length());
        }

        // Collect all rows and find max widths
        List<List<String>> rows = new ArrayList<>();
        while (resultSet.next()) {
            List<String> row = new ArrayList<>();
            for (int i = 1; i <= columnCount; i++) {
                Object value = resultSet.getObject(i);
                String strValue = value != null ? value.toString() : "NULL";
                row.add(strValue);
                if (strValue.length() > columnWidths.get(i - 1)) {
                    columnWidths.set(i - 1, strValue.length());
                }
            }
            rows.add(row);
        }

        // Print table
        printSeparator(columnWidths, out);
        printRow(columnNames, columnWidths, out);
        printSeparator(columnWidths, out);

        for (List<String> row : rows) {
            printRow(row, columnWidths, out);
        }

        printSeparator(columnWidths, out);
        out.printf("%d row(s) returned%n", rows.size());
    }

    private void printSeparator(List<Integer> columnWidths, PrintStream out) {
        for (Integer width : columnWidths) {
            out.print(CROSS_CHAR);
            out.print(BORDER_CHAR.repeat(width + 2));
        }
        out.print(CROSS_CHAR);
        out.println();
    }

    private void printRow(List<String> row, List<Integer> columnWidths, PrintStream out) {
        for (int i = 0; i < row.size(); i++) {
            String value = row.get(i);
            int width = columnWidths.get(i);
            out.print(PIPE_CHAR);
            out.print(" ");
            out.printf("%-" + width + "s", value);
            out.print(" ");
        }
        out.print(PIPE_CHAR);
        out.println();
    }
}