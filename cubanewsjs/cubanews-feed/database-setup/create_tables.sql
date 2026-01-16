CREATE TABLE feed (
    id SERIAL PRIMARY KEY,
    feedts BIGINT,
    feedisodate VARCHAR(25),
    source VARCHAR(100),
    title TEXT,
    url TEXT,
    content TEXT,
    updated BIGINT,
    isodate VARCHAR(25),
    score DOUBLE PRECISION DEFAULT 0.0
);

CREATE TABLE subscriptions (
    id SERIAL PRIMARY KEY,
    email varchar(200),
    status varchar(50),
    timestamp BIGINT
);

CREATE TABLE interactions (
    id SERIAL PRIMARY KEY,
    feedid INTEGER,
    interaction varchar(50),
    timestamp BIGINT,
    FOREIGN KEY (feedid) REFERENCES feed(id)
);
