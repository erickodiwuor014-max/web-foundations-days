\# Library Books REST API



This API manages a collection of books.



\## 1. List all books



\* \*\*Method:\*\* GET

\* \*\*Path:\*\* `/books`

\* \*\*Description:\*\* Returns a list of all books.

\* \*\*Success:\*\* `200 OK`



\### Example request



```http

GET /books

```



\---



\## 2. Get one book



\* \*\*Method:\*\* GET

\* \*\*Path:\*\* `/books/:id`

\* \*\*Description:\*\* Returns one book using its ID.

\* \*\*Success:\*\* `200 OK`



\### Example request



```http

GET /books/12

```



\---



\## 3. Create a book



\* \*\*Method:\*\* POST

\* \*\*Path:\*\* `/books`

\* \*\*Description:\*\* Creates a new book.

\* \*\*Success:\*\* `201 Created`



\### Example request body



```json

{

&#x20; "title": "Things Fall Apart",

&#x20; "author": "Chinua Achebe"

}

```



\---



\## 4. Update a book



\* \*\*Method:\*\* PUT

\* \*\*Path:\*\* `/books/:id`

\* \*\*Description:\*\* Updates an existing book using its ID.

\* \*\*Success:\*\* `200 OK`



\### Example request



```http

PUT /books/12

```



\### Example request body



```json

{

&#x20; "title": "Things Fall Apart",

&#x20; "author": "Chinua Achebe"

}

```



\---



\## 5. Delete a book



\* \*\*Method:\*\* DELETE

\* \*\*Path:\*\* `/books/:id`

\* \*\*Description:\*\* Deletes an existing book using its ID.

\* \*\*Success:\*\* `204 No Content`



\### Example request



```http

DELETE /books/12

```



\---



\## 6. List books by author



\* \*\*Method:\*\* GET

\* \*\*Path:\*\* `/books?author=Chinua%20Achebe`

\* \*\*Description:\*\* Returns books written by the specified author using a query parameter.

\* \*\*Success:\*\* `200 OK`



\### Example request



```http

GET /books?author=Chinua%20Achebe

```



\---



\# Error Responses



\## 400 Bad Request



The server returns `400 Bad Request` when the request is invalid or missing required information.



\### Example



A client tries to create a book without providing a title:



```json

{

&#x20; "author": "Chinua Achebe"

}

```



Response:



```http

400 Bad Request

```



\---



\## 404 Not Found



The server returns `404 Not Found` when the requested book does not exist.



\### Example



A client requests a book with an ID that does not exist:



```http

GET /books/9999

```



Response:



```http

404 Not Found

```



