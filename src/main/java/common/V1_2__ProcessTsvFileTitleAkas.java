package main.java.common;

import org.flywaydb.core.api.migration.Context;

import java.sql.SQLException;

public class V1_2__ProcessTsvFileTitleAkas extends ProcessTsvFile {
    public V1_2__ProcessTsvFileTitleAkas(Context context, String tsvFileName) {
        super(context, tsvFileName);
    }

    @Override
    public void processRow(String[] row) {
        try {
            String sql;
            if (tsvProcessedCount != 0) {
                sql = "INSERT INTO TITLE_AKA (TCONST, ORDERING, TITLE, REGION, LANGUAGE, TYPES, ATTRIBUTES, IS_ORIGINAL_TITLE) VALUES (";
                sql += "'" + row[0] + "' "; // tconst
                sql += ", '" + processInteger(row[1]) + "' "; // ordering
                sql += ", '" + processEscapedQuotes(row[2]) + "' "; // title
                sql += ", '" + processEscapedQuotes(row[3]) + "' "; // region
                sql += ", '" + processEscapedQuotes(row[4]) + "' "; // language
                sql += ", '" + processEscapedQuotes(row[5]) + "' "; // types
                sql += ", '" + processEscapedQuotes(row[6]) + "' "; // attributes
                sql += ", '" + processBoolean(row[7]) + "'"; // isOriginalTitle
                sql += ")";
                statement.execute(sql);
            }
        } catch (SQLException e) {
            System.err.println("Got an SQLException! ");
            System.err.println(e.getMessage());
        }
    }
}
