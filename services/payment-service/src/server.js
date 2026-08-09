const express = require("express");

const app = express();

app.use(express.json());

app.get("/health", (req, res) => {
    res.status(200).json({
        service: "payment-service",
        status: "healthy"
    });
});

app.get("/api/payments", (req, res) => {
    res.status(200).json({
        payments: []
    });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
    console.log(`Payment service running on port ${PORT}`);
});