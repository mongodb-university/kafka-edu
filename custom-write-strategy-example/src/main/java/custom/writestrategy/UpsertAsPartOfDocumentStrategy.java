/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package custom.writestrategy;

import com.mongodb.client.model.Filters;
import com.mongodb.client.model.UpdateOneModel;
import com.mongodb.client.model.UpdateOptions;
import com.mongodb.client.model.WriteModel;
import com.mongodb.kafka.connect.sink.converter.SinkDocument;
import com.mongodb.kafka.connect.sink.writemodel.strategy.WriteModelStrategy;
import org.apache.kafka.connect.errors.DataException;
import org.bson.BsonDocument;


public class UpsertAsPartOfDocumentStrategy implements WriteModelStrategy {

    private final static String ID_FIELD_NAME = "_id";
    private final static String EVENT_TYPE_FIELD_NAME = "eventType";
    @Override
    public WriteModel<BsonDocument> createWriteModel(SinkDocument sinkDocument) {
        // Get old document
        BsonDocument changeStreamDocument = sinkDocument.getValueDoc().orElseThrow(() -> new DataException("Missing Value Document"));
        BsonDocument fullDocument = changeStreamDocument.getDocument("fullDocument", new BsonDocument());
        if (fullDocument.isEmpty()) {
            return null;
        }
        // Extract event type from document
        String eventType = "";
        try {
            eventType = fullDocument.get(EVENT_TYPE_FIELD_NAME).toString();
        } catch (Exception ex) {
            String errorMessage = String.format("Encountered an exception when attempting to retrieve field %s from fulldocument: ", EVENT_TYPE_FIELD_NAME);
            System.out.println(errorMessage + ex);
            return null;
        }
        // Create new document where old one is nested
        BsonDocument newDocument = new BsonDocument().append(eventType, fullDocument);
        // Create WriteModel
        UpdateOptions upsertOption = new UpdateOptions().upsert(true);
        return new UpdateOneModel<>(Filters.eq(ID_FIELD_NAME, fullDocument.get(ID_FIELD_NAME)), newDocument, upsertOption);
    }
}
