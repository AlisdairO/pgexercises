package com.pgexercises.monitor.serialization;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonValue;
import org.apache.commons.lang3.Validate;
import org.apache.commons.lang3.builder.EqualsBuilder;
import org.apache.commons.lang3.builder.HashCodeBuilder;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@JsonIgnoreProperties(ignoreUnknown = true)
public class ResultsTable {
    List<List<String>> results;

    @JsonCreator
    public ResultsTable(List<List<String>> results) {
        this.results = results;
    }

    @JsonValue
    public List<List<String>> getResults() {
        return results;
    }

    public boolean matches(@NotNull ResultsTable other, boolean sorted) {
        Validate.notNull(other);
        List<List<String>> otherTable = new ArrayList<>(other.getResults());
        List<List<String>> thisTable = new ArrayList<>(this.getResults());
        if (!sorted) {
            otherTable.sort(Comparator.comparing(x -> x.stream().collect(Collectors.joining(","))));
            thisTable.sort(Comparator.comparing(x -> x.stream().collect(Collectors.joining(","))));
        }
        return otherTable.equals(thisTable);
    }

    @Override
    public String toString() {
        return ToStringBuilder.reflectionToString(this);
    }

    @Override
    public boolean equals(Object that) {
        return EqualsBuilder.reflectionEquals(this, that);
    }

    @Override
    public int hashCode() {
        return HashCodeBuilder.reflectionHashCode(this);
    }
}
