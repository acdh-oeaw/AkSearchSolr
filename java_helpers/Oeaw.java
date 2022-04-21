import java.util.Collection;
import java.util.List;
import java.util.LinkedList;
import org.marc4j.marc.Record;
import org.marc4j.marc.DataField;
import org.marc4j.marc.Subfield;
import org.marc4j.marc.VariableField;

public class Oeaw {
    public Collection<String> getRepeated(Record record, String description) {
        List<String> result = new LinkedList<String>();
        DataField field;
        for (String desc : description.split(":")) {
            String[] parts = desc.split("[|]");
            String fieldNo = parts[0];
            char ind1 = parts[1].charAt(0);
            char ind2 = parts[1].charAt(1);
            String subfields = parts[2];
            String countSubfield = parts[3];
            for (VariableField varField : record.getVariableFields(parts[0])) {
                field = (DataField) varField;
                // filter based on indicators
                if (!(ind1 == '_' || ind1 == '#' && field.getIndicator1() == ' ' || ind1 == field.getIndicator1())) {
                    continue;
                }
                if (!(ind2 == '_' || ind2 == '#' && field.getIndicator2() == ' ' || ind2 == field.getIndicator2())) {
                    continue;
                }
                // compose the value
                String value = "";
                for (int i = 0; i < subfields.length(); i++) {
                    Subfield subfield = field.getSubfield(subfields.charAt(i));
                    if (subfield != null) {
                        value = value + subfield.getData().trim() + " ";
                    }
                }
                value = value.trim();
                // handle repetition
                int count = field.getSubfields(countSubfield.charAt(0)).size();
		if (count == 0) {
                    count = 1;
                }
                for (int i = 0; i < count; i++) {
                    result.add(value);
                }
            }
        }
        return result;
    }

    public Collection<String> getSubfieldAtLeastOnce(Record record, String description, String defaultValue) {
        List<String> result = new LinkedList<String>();
        DataField field;
        for (String desc : description.split(":")) {
            String[] parts = desc.split("[|]");
            String fieldNo = parts[0];
            char ind1 = parts[1].charAt(0);
            char ind2 = parts[1].charAt(1);
            char subfieldCode = parts[2].charAt(0);
            for (VariableField varField : record.getVariableFields(parts[0])) {
                field = (DataField) varField;
                // filter based on indicators
                if (!(ind1 == '_' || ind1 == '#' && field.getIndicator1() == ' ' || ind1 == field.getIndicator1())) {
                    continue;
                }
                if (!(ind2 == '_' || ind2 == '#' && field.getIndicator2() == ' ' || ind2 == field.getIndicator2())) {
                    continue;
                }
		boolean hit = false;
                for (Subfield subfield : field.getSubfields(subfieldCode)) {
                    result.add(subfield.getData().trim());
		    hit = true;
		}
                if (!hit) {
                    result.add(defaultValue);
                }
            }
        }
        return result;
    }
}

