create table fct_visits
(
  child_id integer,
  year_last_visit integer, 
  month_last_visit integer,
  day_last_visit integer,
  days_since_last_visit integer 
);


create table dim_people
(
  person_id integer,
  gender character varying(255),
  year_of_birth integer,
  month_of_birth integer,
  day_of_birth integer,
  race character varying(255),
  county character varying(255),
  multi_racial boolean,
  age_rounded_in_years integer,
  CONSTRAINT people_pkey PRIMARY KEY (person_id)
);


