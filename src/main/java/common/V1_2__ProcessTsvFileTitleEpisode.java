package main.java.common;

import org.flywaydb.core.api.migration.Context;

import java.sql.SQLException;

public class V1_2__ProcessTsvFileTitleEpisode extends ProcessTsvFile {
    public V1_2__ProcessTsvFileTitleEpisode(Context context, String tsvFileName) {
        super(context, tsvFileName);
    }

    @Override
    public void processRow(String[] row) {
        try {
            String sql;
            if (tsvProcessedCount != 0) {
                sql = "INSERT INTO TITLE_EPISODE (TCONST, TCONST_PARENT, SEASON_NUMBER, EPISODE_NUMBER) VALUES (";
                sql += "'" + row[0] + "' "; // tconst
                sql += ", '" + row[1] + "' "; // tconstParent
                sql += ", '" + processInteger(row[2]) + "' "; // seasonNumber
                sql += ", '" + processInteger(row[3]) + "'"; // episodeNumber
                sql += ")";
                statement.execute(sql);
            }
        } catch (SQLException e) {
            System.err.println("Got an SQLException! ");
            System.err.println(e.getMessage());
        }
    }
}
