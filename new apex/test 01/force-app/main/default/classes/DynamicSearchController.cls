public class DynamicSearchController {
    
    @InvocableMethod(label='Dynamic Search Controller' description='Search Account by field and value')
    public static List<List<Account>> search(List<SearchInput> inputs) {
        List<List<Account>> output = new List<List<Account>>();
        List<Account> results = new List<Account>();

        if (inputs != null && !inputs.isEmpty()) {
            String fieldName = inputs[0].fieldName;
            String fieldValue = '%' + String.escapeSingleQuotes(inputs[0].fieldValue) + '%';

            // Construct dynamic SOQL query
            String query = 'SELECT Id, Name, Industry, Phone FROM Account WHERE ' + fieldName + ' LIKE :fieldValue';
            results = Database.query(query);
        }

        output.add(results);
        return output;
    }

    public class SearchInput {
        @InvocableVariable(label='Field Name')
        public String fieldName;

        @InvocableVariable(label='Field Value')
        public String fieldValue;
    }
}