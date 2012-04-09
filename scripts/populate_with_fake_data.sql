DROP FUNCTION IF EXISTS populate_with_fake_data(integer, integer); 

TRUNCATE TABLE fct_visits;
TRUNCATE TABLE dim_people;

CREATE FUNCTION populate_with_fake_data(numberOfPeople integer,
                                       nChildrenInPlacement integer) 
                                    RETURNS void AS $$

  DECLARE 
    startPersonID integer := 130365;
    person_id dim_people.person_id%TYPE;
    randomValue numeric; --double precision
    gender dim_people.gender%TYPE;
    age_in_days integer;
    date_of_birth date;
    race_id integer;
    race dim_people.race%TYPE;
    --races dim_people.race%TYPE[];
    races varchar(255)[];
    year_of_birth dim_people.year_of_birth%TYPE;
    month_of_birth dim_people.month_of_birth%TYPE;
    day_of_birth dim_people.day_of_birth%TYPE;
    current_year integer;
    current_month integer;
    current_day integer;
    probability numeric;
    date_last_visit date;
    days_since_last_visit integer;
    year_last_visit fct_visits.year_last_visit%TYPE;
    month_last_visit fct_visits.month_last_visit%TYPE;
    day_last_visit fct_visits.day_last_visit%TYPE;
    n_people integer;
    n_children_with_visits integer;

  BEGIN
       n_people := 0;
       n_children_with_visits := 0;
       races := '{"american_indian", "asian", "black", "pacific_islander","white"}';
       probability := 
         cast(nChildrenInPlacement as real)/cast(numberOfPeople as real);
       RAISE NOTICE 'probability = %', probability;
       FOR i IN 1..numberOfPeople LOOP
         person_id := startPersonID + i - 1;
         randomValue := random();
         IF randomValue >= 0.5 THEN 
           gender := 'Male';
         ELSE 
           gender := 'Female';
         END IF;
         randomValue := random();
         age_in_days := ceiling(randomValue*365*18);
         date_of_birth := current_date - age_in_days;
         year_of_birth :=  date_part('year', date_of_birth);
         month_of_birth :=  date_part('month', date_of_birth);
         day_of_birth :=  date_part('day', date_of_birth);
         randomValue := random();
         --race can be american_indian, asian, black, pacific_islander or white
        
         race_id := ceiling(randomValue*5);
         race := races[race_id];
         /*RAISE NOTICE 'person_id = %, gender = %, date of birth = %-%-%, race = %',
                      person_id, gender, year_of_birth, month_of_birth, 
                      day_of_birth, race;*/
         n_people := n_people + 1;
         IF (n_people%10000 = 0) THEN
           RAISE NOTICE 'n_people = %', n_people;
         END IF;
         insert into dim_people(person_id, gender, year_of_birth, month_of_birth,
                                day_of_birth, race)
                values (person_id, gender, year_of_birth, month_of_birth,
                                day_of_birth, race);
                 randomValue := random();
         IF (randomValue <= probability) THEN
           --This child is being sampled as a child in placement 
           --and one who had a visit with a caseworker. Choose the 
           --date of last visit as a date between the date of birth
           --of the child and today.
           randomValue := random();
           days_since_last_visit := ceiling(randomValue*age_in_days);
           date_last_visit := current_date - days_since_last_visit;
           year_last_visit :=  date_part('year', date_last_visit);
           month_last_visit :=  date_part('month', date_last_visit);
           day_last_visit := date_part('day', date_last_visit);
           /*RAISE NOTICE 'child_id = %, date of last visit = %-%-%',
                      person_id, year_last_visit, month_last_visit, 
                      day_last_visit;*/
           n_children_with_visits := n_children_with_visits + 1;
           IF (n_children_with_visits%100 = 0) THEN 
             RAISE NOTICE 'n_children_with_visits = %', n_children_with_visits;
           END IF;
           insert into fct_visits(child_id, year_last_visit, month_last_visit,
                                   day_last_visit, days_since_last_visit)
                       values (person_id, year_last_visit, month_last_visit,
                               day_last_visit, days_since_last_visit);
          END IF;
    END LOOP;
  END;
$$ LANGUAGE plpgsql;

--SELECT populate_with_fake_data();
