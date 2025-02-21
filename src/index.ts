import express from "express";
import authRouter from "./routes/auth";

const app = express();

app.get("/", (req, res) => {
    res.send("Welcome to the backend");
});

// middleware
app.use(express.json()); 

// routes
app.use("/auth", authRouter);

app.listen(8000, () => {
    console.log("Server is running on port 8000");
});

