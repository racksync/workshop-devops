package main

import (
	"context"
	"encoding/json"
	"html/template"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/jackc/pgx/v5"
)

// Data structure to hold dynamic content for rendering
type PageData struct {
	Title   string
	Message string
	Posts   []BlogPost
}

type BlogPost struct {
	Title   string
	Content string
	Date    time.Time
}

type Submission struct {
	Title   string
	Content string
}

var CONN_STR = ""

var conn *pgx.Conn

// Handler function to render the main page
func handler(w http.ResponseWriter, r *http.Request) {

	var posts []BlogPost

	rows, err := conn.Query(context.Background(), "SELECT title, content, date FROM posts ORDER BY date DESC")
	if err != nil {
		panic(err)
	}

	defer rows.Close()
	for rows.Next() {
		var post BlogPost
		if err := rows.Scan(&post.Title, &post.Content, &post.Date); err != nil {
			panic(err)
		}
		posts = append(posts, post)
	}

	data := PageData{
		Title:   "Hello, Go Server!",
		Message: "This is server-side rendered content in Go.",
		Posts:   posts,
	}

	// Parse and execute template
	tmpl, err := template.ParseFiles("templates/index.html")
	if err != nil {
		http.Error(w, "Error parsing template", http.StatusInternalServerError)
		return
	}
	if err := tmpl.Execute(w, data); err != nil {
		http.Error(w, "Error executing template", http.StatusInternalServerError)
	}
}

func submit(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		return
	}

	var s Submission

	err := json.NewDecoder(r.Body).Decode(&s)
	if err != nil {
		http.Error(w, "Bad Request", http.StatusBadRequest)
		return
	}

	if len(s.Title) < 3 || len(s.Title) > 256 {
		http.Error(w, "Title size is bad", http.StatusBadRequest)
		return
	}

	if len(s.Content) < 3 || len(s.Content) > 10000 {
		http.Error(w, "Content size is bad", http.StatusBadRequest)
		return
	}

	query := "INSERT INTO posts (title, content, date) VALUES ($1, $2, NOW())"
	_, err = conn.Exec(context.Background(), query, s.Title, s.Content)
	if err != nil {
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
	}

}

func main() {

	CONN_STR = os.Getenv("CONN_STR")
	if CONN_STR == "" {
		panic("empty CONN_STR")
	}

	var err error
	conn, err = pgx.Connect(context.Background(), CONN_STR)
	if err != nil {
		panic(err)
	}
	defer conn.Close(context.Background())

	_, err = conn.Exec(context.Background(), "CREATE TABLE IF NOT EXISTS posts(id SERIAL PRIMARY KEY, title VARCHAR(256), content TEXT, date TIMESTAMPTZ);")
	if err != nil {
		panic(err)
	}

	// Register handler function for the root path
	http.HandleFunc("/", handler)
	http.HandleFunc("/submit", submit)

	// Start server on port 8080
	log.Println("Server started at :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
