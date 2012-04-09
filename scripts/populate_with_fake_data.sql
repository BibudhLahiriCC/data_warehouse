DROP FUNCTION IF EXISTS populate_with_fake_data(integer, integer); 

TRUNCATE TABLE fct_visits;
TRUNCATE TABLE dim_people;
TRUNCATE TABLE fct_removal_episodes;

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
    days_since_start_removal_episode integer;
    days_to_end_removal_episode integer;
    length_of_removal_episode_till_date integer;
    start_date_removal_episode date;
    end_date_removal_episode date;
    anchor_date date;
    days_to_anchor_date integer;

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
         anchor_date := to_date('2013-09-30', 'YYYY-MM-DD');
         IF (randomValue <= probability) THEN
           /*This child is being sampled as a child in placement 
             and one who had a visit with a caseworker. For removal 
             episode, choose the start date as a date between the date
             of birth of the child and today. Choose the end date as a
             date between the start date and the anchor_date. Choose the date of 
             last visit as a date between the start date of the removal 
             episode and today.*/
           randomValue := random();
           
           days_since_start_removal_episode := 
             ceiling(randomValue*age_in_days);
           start_date_removal_episode := current_date 
              - days_since_start_removal_episode;
           randomValue := random();
           --The end date can be in past or in future
           days_to_anchor_date := anchor_date - start_date_removal_episode;
           days_to_end_removal_episode := 
             floor(randomValue*days_to_anchor_date);
            end_date_removal_episode := start_date_removal_episode +  
              days_to_end_removal_episode;

           insert into fct_removal_episodes (child_id, start_date,
                                             end_date, type)
                      values (person_id, start_date_removal_episode,
                              end_date_removal_episode, 'PhysicalLocation::Placement');
           length_of_removal_episode_till_date := current_date 
              - start_date_removal_episode + 1;
           randomValue := random();
           date_last_visit := start_date_removal_episode + 
              cast(floor(randomValue*length_of_removal_episode_till_date) as integer);
           days_since_last_visit := current_date - date_last_visit;
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
