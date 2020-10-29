package com.pgexercises.monitor.serialization;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.apache.commons.lang3.builder.EqualsBuilder;
import org.apache.commons.lang3.builder.HashCodeBuilder;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.checkerframework.checker.nullness.qual.NonNull;
import org.checkerframework.checker.nullness.qual.Nullable;
import org.checkerframework.framework.qual.DefaultQualifier;
import org.checkerframework.framework.qual.TypeUseLocation;

import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
@DefaultQualifier(value = NonNull.class, locations = TypeUseLocation.LOCAL_VARIABLE)
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
    public boolean equals(@Nullable Object that) {
        if (that == null) {
            return false;
        }
        return EqualsBuilder.reflectionEquals(this, that);
    }

    @Override
    public int hashCode() {
        return HashCodeBuilder.reflectionHashCode(this);
    }
}
