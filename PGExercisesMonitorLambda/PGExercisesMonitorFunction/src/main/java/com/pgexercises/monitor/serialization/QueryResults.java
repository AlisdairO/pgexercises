package com.pgexercises.monitor.serialization;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.apache.commons.lang3.builder.EqualsBuilder;
import org.apache.commons.lang3.builder.HashCodeBuilder;
import org.apache.commons.lang3.builder.ToStringBuilder;

import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public class QueryResults {
    private final List<String> headers;
    private final ResultsTable values;

    @JsonCreator
    public QueryResults(@JsonProperty("headers") List<String> headers,
                        @JsonProperty("values") ResultsTable values) {
        this.headers = headers;
        this.values = values;
    }

    public List<String> getHeaders() {
        return headers;
    }

    public ResultsTable getValues() {
        return values;
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
