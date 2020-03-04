package main.java.db.migration;

import main.java.common.*;
import org.flywaydb.core.api.migration.BaseJavaMigration;
import org.flywaydb.core.api.migration.Context;

public class V1_2__Load_Initial_IMDB_Data extends BaseJavaMigration {
    public void migrate(Context context) throws Exception {
        new V1_2__ProcessTsvFileNameBasics(context, "src/main/java/common/data/name.basics.tsv.smaller").execute();
        new V1_2__ProcessTsvFileTitleAkas(context, "src/main/java/common/data/title.akas.tsv.smaller").execute();
        new V1_2__ProcessTsvFileTitleBasics(context, "src/main/java/common/data/title.basics.tsv.smaller").execute();
        new V1_2__ProcessTsvFileTitleCrew(context, "src/main/java/common/data/title.crew.tsv.smaller").execute();
        new V1_2__ProcessTsvFileTitleEpisode(context, "src/main/java/common/data/title.episode.tsv.smaller").execute();
        new V1_2__ProcessTsvFileTitlePrincipals(context, "src/main/java/common/data/title.principals.tsv.smaller").execute();
        new V1_2__ProcessTsvFileTitleRatings(context, "src/main/java/common/data/title.ratings.tsv.smaller").execute();
    }
}