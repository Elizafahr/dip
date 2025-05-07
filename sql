-- 1. Пользователи (Users)
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'organizer', 'user')),
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- 2. Организаторы (Organizers)
CREATE TABLE Organizers (
    organizer_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES Users(user_id),
    organization_name VARCHAR(100) NOT NULL,
    description TEXT,
    logo_url VARCHAR(255),
    contact_person VARCHAR(100),
    is_verified BOOLEAN DEFAULT FALSE
);

-- 3. Мероприятия (Events)
CREATE TABLE Events (
    event_id SERIAL PRIMARY KEY,
    organizer_id INT NOT NULL REFERENCES Organizers(organizer_id),
    title VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,
    start_datetime TIMESTAMP NOT NULL,
    end_datetime TIMESTAMP NOT NULL,
    location VARCHAR(255) NOT NULL,
    age_restriction INT,
    poster_url VARCHAR(255),
    is_published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Билеты (Tickets) – для мероприятий без мест
CREATE TABLE Tickets (
    ticket_id SERIAL PRIMARY KEY,
    event_id INT NOT NULL REFERENCES Events(event_id),
    ticket_type VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    quantity_available INT NOT NULL,
    booking_start TIMESTAMP,
    booking_end TIMESTAMP
);

-- 5. Места (Seats) – для мероприятий с фиксированными местами
CREATE TABLE Seats (
    seat_id SERIAL PRIMARY KEY,
    event_id INT NOT NULL REFERENCES Events(event_id),
    seat_number VARCHAR(10) NOT NULL,
    zone VARCHAR(50),
    row_number INT,
    is_reserved BOOLEAN DEFAULT FALSE,
    price_multiplier DECIMAL(3, 2) DEFAULT 1.0
);

-- 6. Бронирования (Bookings)
CREATE TABLE Bookings (
    booking_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES Users(user_id),
    ticket_id INT REFERENCES Tickets(ticket_id),
    seat_id INT REFERENCES Seats(seat_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    total_price DECIMAL(10, 2) NOT NULL,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')),
    payment_method VARCHAR(50),
    CONSTRAINT chk_booking_type CHECK (
        (ticket_id IS NOT NULL AND seat_id IS NULL) OR 
        (ticket_id IS NULL AND seat_id IS NOT NULL)
    )
);

-- 7. Отзывы (Reviews)
CREATE TABLE Reviews (
    review_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES Users(user_id),
    event_id INT NOT NULL REFERENCES Events(event_id),
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. Избранное (Favorites)
CREATE TABLE Favorites (
    favorite_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES Users(user_id),
    event_id INT NOT NULL REFERENCES Events(event_id),
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, event_id)
);

-- 9. Новости (News) – от организаторов
CREATE TABLE News (
    news_id SERIAL PRIMARY KEY,
    organizer_id INT NOT NULL REFERENCES Organizers(organizer_id),
    title VARCHAR(100) NOT NULL,
    content TEXT,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_pinned BOOLEAN DEFAULT FALSE
);

-- 10. Уведомления (Notifications) – опционально
CREATE TABLE Notifications (
    notification_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES Users(user_id),
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
