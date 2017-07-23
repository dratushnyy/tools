package main

import (
    "net/http"
    "fmt"
    "os"
    "log"
    "strings"
)


func redirect(w http.ResponseWriter, r *http.Request) {
    to := r.URL.Query().Get("to")
    if len(to) == 0 {
        to = "http://dratushnyy.me"
    }else{
        if ! strings.Contains(to, "://") {
            to = fmt.Sprintf("http://%s", to)
        }
    }
    fmt.Printf("Redirect to '%s'\n", to)
    http.Redirect(w, r, to, 301)
}


func main() {
    LISTEN_ON  := "80"
    if len(os.Args) > 1 {
        LISTEN_ON  = os.Args[1]
    }
    http.HandleFunc("/", redirect)

    err := http.ListenAndServe(fmt.Sprintf(":%s", LISTEN_ON), nil)
    if err != nil {
        log.Fatal("ListenAndServe: ", err)
    }
}