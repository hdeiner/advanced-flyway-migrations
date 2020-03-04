package main.java.common;

import org.flywaydb.core.api.migration.Context;

import java.sql.SQLException;

public class V1_2__ProcessTsvFileTitleRatings extends ProcessTsvFile {
    public V1_2__ProcessTsvFileTitleRatings(Context context, String tsvFileName) {
        super(context, tsvFileName);
    }

    @Override
    public void processRow(String[] row) {
        try {
            String sql;
            if (tsvProcessedCount != 0) {
                sql = "INSERT INTO TITLE_RATING (TCONST, AVERAGE_RATING, NUMBER_OF_VOTES) VALUES (";
                sql += "'" + row[0] + "' "; // tconst
                sql += ", '" + row[1] + "' "; // averageRating
                sql += ", '" + processInteger(row[2]) + "'"; // numberOfVotes
                sql += ")";
                statement.execute(sql);
            }
        } catch (SQLException e) {
            System.err.println("Got an SQLException! ");
            System.err.println(e.getMessage());
        }
    }
}
