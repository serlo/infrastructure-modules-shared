import mysql.connector
import os
import psycopg2

mysql_connection = None
postgres_connection = None


def main():
    try:
        mysql_connection = mysql.connector.connect(
            host=os.getenv("MYSQL_HOST"),
            database="serlo",
            user=os.getenv("MYSQL_USER"),
            password=os.getenv("MYSQL_PASSWORD"),
        )
        if not mysql_connection.is_connected():
            raise Exception("Could not connect to mysql database")
        postgres_connection = psycopg2.connect(
            database="kratos",
            host=os.getenv("POSTGRES_HOST"),
            user="serlo",
            password=os.getenv("POSTGRES_PASSWORD"),
        )
        mysql_cursor = mysql_connection.cursor()
        mysql_cursor.execute("select user_id, value from user_field")
        user_field_results = mysql_cursor.fetchall()
        users_ids = tuple(str(result[0]) for result in user_field_results)
        postgres_cursor = postgres_connection.cursor()
        postgres_cursor.execute(
            "UPDATE identities SET traits = traits || '{\"interest\": \"\"}' WHERE metadata_public ->> 'legacy_id' NOT IN %s",
            [users_ids],
        )

        users_ids_by_interest = sort_users_ids_by_interest(user_field_results)
        print(users_ids_by_interest)

        for interest in users_ids_by_interest:
            postgres_cursor.execute(
                "UPDATE identities SET traits = JSONB_SET(traits, '{interest}', TO_JSONB(%s::text)) WHERE metadata_public ->> 'legacy_id' IN %s",
                [interest, users_ids_by_interest[interest]],
            )

        postgres_connection.commit()
        print('success')
    except Exception as exception:
        raise exception
    finally:
        if mysql_connection is not None:
            mysql_connection.close()
        if postgres_connection is not None:
            postgres_connection.close()


def sort_users_ids_by_interest(user_field_results):
    def make_users_ids_interested_in(interest):
        return tuple(
            str(result[0])
            for result in [
                result for result in user_field_results if result[1] == interest
            ]
        )

    all_interests = {result[1] for result in user_field_results}

    return {
        interest: make_users_ids_interested_in(interest) for interest in all_interests
    }

if __name__ == "__main__":
    main()
