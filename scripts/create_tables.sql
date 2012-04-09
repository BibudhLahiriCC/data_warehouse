create table fct_visits
(
  child_id integer,
  year_last_visit integer, 
  month_last_visit integer,
  day_last_visit integer,
  days_since_last_visit integer 
);

CREATE TABLE fct_removal_episodes
(
  removal_episode_id serial NOT NULL,
  child_id integer,
  start_date date,
  end_date date,
  type character varying(50),
  CONSTRAINT removal_episodes_pkey PRIMARY KEY (removal_episode_id )
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


