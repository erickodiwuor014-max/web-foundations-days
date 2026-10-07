\# Library Books API



\## 1. Get all books



\- Method: GET

\- Path: /books

\- Description: Gets all books.

\- Success: 200 OK



\## 2. Get one book



\- Method: GET

\- Path: /books/:id

\- Description: Gets one book by ID.

\- Success: 200 OK



\## 3. Create a book



\- Method: POST

\- Path: /books

\- Description: Creates a new book.

\- Body:

```json

{

&#x20; "title": "Things Fall Apart",

&#x20; "author": "Chinua Achebe"

}

