--
-- TOC entry 2196 (class 2606 OID 32822)
-- Name: bookings_pk; Type: CONSTRAINT; Schema: cd; Owner: -; Tablespace:
--

ALTER TABLE ONLY bookings
    ADD CONSTRAINT bookings_pk PRIMARY KEY (bookid);


--
-- TOC entry 2192 (class 2606 OID 32777)
-- Name: facilities_pk; Type: CONSTRAINT; Schema: cd; Owner: -; Tablespace:
--

ALTER TABLE ONLY facilities
    ADD CONSTRAINT facilities_pk PRIMARY KEY (facid);


--
-- TOC entry 2194 (class 2606 OID 32807)
-- Name: members_pk; Type: CONSTRAINT; Schema: cd; Owner: -; Tablespace:
--

ALTER TABLE ONLY members
    ADD CONSTRAINT members_pk PRIMARY KEY (memid);


--
-- TOC entry 2198 (class 2606 OID 32823)
-- Name: fk_bookings_facid; Type: FK CONSTRAINT; Schema: cd; Owner: -
--

ALTER TABLE ONLY bookings
    ADD CONSTRAINT fk_bookings_facid FOREIGN KEY (facid) REFERENCES facilities(facid);


--
-- TOC entry 2199 (class 2606 OID 32828)
-- Name: fk_bookings_memid; Type: FK CONSTRAINT; Schema: cd; Owner: -
--

ALTER TABLE ONLY bookings
    ADD CONSTRAINT fk_bookings_memid FOREIGN KEY (memid) REFERENCES members(memid);


--
-- TOC entry 2197 (class 2606 OID 32808)
-- Name: fk_members_recommendedby; Type: FK CONSTRAINT; Schema: cd; Owner: -
--

ALTER TABLE ONLY members
    ADD CONSTRAINT fk_members_recommendedby FOREIGN KEY (recommendedby) REFERENCES members(memid) ON DELETE SET NULL;


-- Completed on 2013-05-19 16:05:12 BST

--
-- PostgreSQL database dump complete
--

CREATE INDEX "bookings.memid_facid"
  ON cd.bookings
  USING btree
  (memid, facid);

CREATE INDEX "bookings.facid_memid"
  ON cd.bookings
  USING btree
  (facid, memid);

CREATE INDEX "bookings.facid_starttime"
  ON cd.bookings
  USING btree
  (facid, starttime);

CREATE INDEX "bookings.memid_starttime"
  ON cd.bookings
  USING btree
  (memid, starttime);

CREATE INDEX "bookings.starttime"
  ON cd.bookings
  USING btree
  (starttime);

CREATE INDEX "members.joindate"
  ON cd.members
  USING btree
  (joindate);

CREATE INDEX "members.recommendedby"
  ON cd.members
  USING btree
  (recommendedby);

alter database exercises set default_transaction_read_only = on;
GRANT SELECT ON ALL TABLES IN SCHEMA cd TO pgexercises;

ANALYZE;
