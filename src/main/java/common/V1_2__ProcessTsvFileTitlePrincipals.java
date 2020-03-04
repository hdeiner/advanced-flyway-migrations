package main.java.common;

import org.flywaydb.core.api.migration.Context;

import java.sql.SQLException;

public class V1_2__ProcessTsvFileTitlePrincipals extends ProcessTsvFile {
    public V1_2__ProcessTsvFileTitlePrincipals(Context context, String tsvFileName) {
        super(context,tsvFileName);
    }

    @Override
    public void processRow(String[] row) {
        try {
            String sql;
            if (tsvProcessedCount != 0) {
                sql = "INSERT INTO TITLE_PRINCIPALS (TCONST, ORDERING, NCONST, CATEGORY, JOB, CHARACTER_PLAYED) VALUES (";
                sql += "'" + row[0] + "' "; // tconst
                sql += ", '" + processInteger(row[1]) + "' "; // ordering
                sql += ", '" + row[2] + "' "; // nconst
                sql += ", '" + processEscapedQuotes(row[3]) + "' "; // category
                sql += ", '" + processEscapedQuotes(row[4]) + "' "; // job
                sql += ", '" + processEscapedQuotes(row[5]) + "'"; // character
                sql += ")";
                statement.execute(sql);
            }
        } catch (SQLException e) {
            System.err.println("Got an SQLException! ");
            System.err.println(e.getMessage());
        }
    }
}
