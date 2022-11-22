import java.util.Collection;
import java.util.List;
import java.util.LinkedList;
import java.util.TreeMap;
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
            String defaultValue = parts.length >= 5 ? parts[4] : "";
            for (VariableField varField : record.getVariableFields(parts[0])) {
                field = (DataField) varField;
                // read and sanitize repetition
                int count = field.getSubfields(countSubfield.charAt(0)).size();
                if (count == 0) {
                    count = 1;
                }
                // filter based on indicators
                if (!(ind1 == '_' || ind1 == '#' && field.getIndicator1() == ' ' || ind1 == field.getIndicator1())) {
                    continue;
                }
                if (!(ind2 == '_' || ind2 == '#' && field.getIndicator2() == ' ' || ind2 == field.getIndicator2())) {
                    continue;
                }
                // handle linked field
                int i = 0;
                if (subfields.charAt(0) == '@') {
                    i = 1;
                    Subfield linkSubfield = field.getSubfield('6');
                    if (linkSubfield != null) {
                        String[] link = linkSubfield.getData().split("-");
                        field = this.getLinkedField(record, link[0], field.getTag() + "-" + link[1]);
                    } else {
                        field = null;
                    }
                }
                // compose the value
                String value = "";
                if (field == null) {
                    value = defaultValue;
                } else {
                    int n = 0;
                    for (; i < subfields.length(); i++) {
                        Subfield subfield = field.getSubfield(subfields.charAt(i));
                        if (subfield != null) {
                            value = value + subfield.getData().trim() + " ";
                            n++;
                        }
                    }
                    value = value.trim();
                    if (n == 0) {
                        value = defaultValue;
                    }
                }
                // handle repetition
                for (int j = 0; j < count; j++) {
                    result.add(value);
                }
            }
        }
        return result;
    }

    private DataField getLinkedField(Record record, String tag, String filter) {
        DataField field;
        for (VariableField varField : record.getVariableFields(tag)) {
            field = (DataField) varField;
            Subfield subfield = field.getSubfield('6');
            if (subfield != null && (subfield.getData() == filter || subfield.getData().startsWith(filter + "/"))) {
                return field;
            }
        }
        return null;
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

    public Collection<String> skipTagsAndSort(Collection<String> input, String skipContent) {
        TreeMap<String, String> output = new TreeMap<String, String>();
        for (String item : input) {
            output.put(
                item.replaceAll("<<[^>]*>> *", ""),
                item.replaceAll("<<|>>", "")
            );
        }
        return skipContent.equals("true") ? (Collection<String>) (Collection<?>) output.keySet() : output.values();
    }

    public Collection<String> skipTagsFromFullRecord(Collection<String> input) {
        LinkedList<String> output = new LinkedList<String>();
        for (String item : input) {
            output.add(item.replaceAll("&lt;&lt;", "").replaceAll("&gt;&gt;", ""));
        }
        return output;
    }
}

