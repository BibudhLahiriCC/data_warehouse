/*Function to update the ages of people. Runs once per day. Stores 
  ages in dim_people table.*/

DROP FUNCTION IF EXISTS update_ages(); 

CREATE FUNCTION update_ages() 
                RETURNS void AS $$

  DECLARE 
    age_in_days integer;
    date_of_birth date;
    year_of_birth varchar(4);
    month_of_birth varchar(2);
    day_of_birth varchar(2);

    year_in_age numeric;
    month_in_age numeric; 
    day_in_age numeric;
    age interval;
    age_rnded_in_years integer;

    cursForAgeUpdate CURSOR FOR
      SELECT person_id, dim_people.year_of_birth, 
             dim_people.month_of_birth, dim_people.day_of_birth 
      FROM dim_people;

  BEGIN
    FOR recordFromPeople IN cursForAgeUpdate LOOP
      year_of_birth := 
        replace(quote_literal(recordFromPeople.year_of_birth), E'\'', '');
      month_of_birth := 
         lpad(replace(quote_literal(recordFromPeople.month_of_birth), E'\'', ''),
              2, '0');
      day_of_birth := 
         lpad(replace(quote_literal(recordFromPeople.day_of_birth), E'\'', ''),
              2, '0');
      
      --Get the exact age in year, month and days as of today
      date_of_birth := to_date(year_of_birth || month_of_birth || 
                                      day_of_birth, 'YYYYMMDD');
      age := age(current_date, date_of_birth);
      year_in_age := 
        extract(year from age);
      month_in_age := 
        extract(month from age);
      day_in_age := 
        extract(day from age);
      if (month_in_age > 0 or day_in_age > 0) then 
        age_rnded_in_years := year_in_age + 1;
      else
        age_rnded_in_years := year_in_age;
      end if;
      update dim_people
      set age_rounded_in_years = age_rnded_in_years
      where person_id = recordFromPeople.person_id;
      
    END LOOP;
  END;
$$ LANGUAGE plpgsql;

SELECT update_ages();
