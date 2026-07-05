-- =====================================================================
-- PET CARE MANAGEMENT & RECOMMENDATION SYSTEM
-- =====================================================================
CREATE DATABASE pet_care_management_system;
USE pet_care_management_system;


-- =====================================================================
-- TABLE CREATION
-- =====================================================================

CREATE TABLE users (
    user_id        INT           NOT NULL AUTO_INCREMENT,
    full_name      VARCHAR(100)  NOT NULL,
    email          VARCHAR(150)  NOT NULL,
    password_hash  VARCHAR(255)  NOT NULL,
    phone          VARCHAR(15)   NULL,
    city           VARCHAR(100)  NULL,
    profile_photo  VARCHAR(255)  NULL,
    role           ENUM('ADMIN','USER') NOT NULL DEFAULT 'USER',
    account_status ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    created_at     DATETIME  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_users        PRIMARY KEY (user_id),
    CONSTRAINT uq_users_email  UNIQUE      (email)
);
-- ---------------------

CREATE TABLE pet_category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    description TEXT,
    UNIQUE (category_name)
);

ALTER TABLE pet_category
ADD category_image VARCHAR(255);

-- --------------------

CREATE TABLE breed (
    breed_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    breed_name VARCHAR(100) NOT NULL,
    lifespan VARCHAR(30),
    temperament VARCHAR(150),
    climate_suitability ENUM('HOT', 'COLD', 'ALL'),
    suitable_for_first_time_owner ENUM('YES', 'NO') NOT NULL DEFAULT 'YES',
    apartment_friendly ENUM('YES', 'NO') NOT NULL DEFAULT 'YES',
    good_with_children ENUM('YES', 'NO') NOT NULL DEFAULT 'YES',
    good_with_other_pets ENUM('YES', 'NO') NOT NULL DEFAULT 'YES',
    min_price DECIMAL(10, 2),
    max_price DECIMAL(10, 2),
    estimated_monthly_cost DECIMAL(10, 2),
    breed_image VARCHAR(255),
    UNIQUE (breed_name),
    FOREIGN KEY (category_id) REFERENCES pet_category(category_id)
);

ALTER TABLE breed
DROP COLUMN lifespan;

ALTER TABLE breed
ADD min_lifespan_years INT NOT NULL,
ADD max_lifespan_years INT NOT NULL;
-- ------------------------------

CREATE TABLE breed_care (
    care_id INT AUTO_INCREMENT PRIMARY KEY,
    breed_id INT NOT NULL,
    recommended_food TEXT,
    foods_to_avoid TEXT,
    grooming_guide TEXT,
    bathing_frequency VARCHAR(50),
    maintenance_tips TEXT,
    youtube_url VARCHAR(255),
    UNIQUE (breed_id),
    FOREIGN KEY (breed_id) REFERENCES breed(breed_id)
);

ALTER TABLE breed_care
CHANGE COLUMN youtube_url reference_link VARCHAR(255);
-- -----------------------

CREATE TABLE vaccination_guide (
    vaccine_id INT AUTO_INCREMENT PRIMARY KEY,
    breed_id INT NOT NULL,
    vaccine_name VARCHAR(100) NOT NULL,
    first_dose_age VARCHAR(50),
    booster_period VARCHAR(50),
    notes TEXT,
    FOREIGN KEY (breed_id) REFERENCES breed(breed_id)
);

-- -------------------------

CREATE TABLE pet_profile (
    pet_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    breed_id INT NOT NULL,
    pet_name VARCHAR(100) NOT NULL,
    pet_photo VARCHAR(255),
    gender ENUM('MALE', 'FEMALE') NOT NULL,
    age_months INT,
    weight DECIMAL(5, 2),
    adoption_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (breed_id) REFERENCES breed(breed_id),
    CHECK (age_months >= 0),
    CHECK (weight > 0)
);

ALTER TABLE pet_profile
MODIFY gender ENUM('MALE','FEMALE','UNKNOWN') NOT NULL;

-- Trigger moved here, right after the table it protects, and before any
-- data is inserted, so validation is active from the very first INSERT.
DELIMITER $$

CREATE TRIGGER CheckPetAge
BEFORE INSERT
ON pet_profile
FOR EACH ROW
BEGIN
    IF NEW.age_months < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Pet age cannot be negative';
    END IF;
END $$

DELIMITER ;

-- ----------------------
CREATE TABLE vaccination_record (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    pet_id INT NOT NULL,
    vaccine_name VARCHAR(100) NOT NULL,
    vaccination_date DATE NOT NULL,
    next_due_date DATE,
    status ENUM('COMPLETED', 'PENDING', 'OVERDUE') NOT NULL DEFAULT 'COMPLETED',
    FOREIGN KEY (pet_id) REFERENCES pet_profile(pet_id)
);

-- -----------------
CREATE TABLE grooming_checklist (
    grooming_id INT AUTO_INCREMENT PRIMARY KEY,
    pet_id INT NOT NULL,
    grooming_date DATE NOT NULL,
    next_due_date DATE,
    remarks TEXT,
    FOREIGN KEY (pet_id) REFERENCES pet_profile(pet_id)
);

-- ----------------------

CREATE TABLE daily_care_checklist (
    task_id INT AUTO_INCREMENT PRIMARY KEY,
    pet_id INT NOT NULL,
    task_name VARCHAR(100) NOT NULL,
    task_date DATE NOT NULL,
    status ENUM('PENDING', 'DONE') NOT NULL DEFAULT 'PENDING',
    FOREIGN KEY (pet_id) REFERENCES pet_profile(pet_id)
);

-- ------------------------

CREATE TABLE user_preferences (
    preference_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    house_type ENUM('APARTMENT', 'HOUSE') NOT NULL,
    budget ENUM('LOW', 'MEDIUM', 'HIGH') NOT NULL,
    climate ENUM('HOT', 'COLD', 'ALL') NOT NULL,
    first_time_owner ENUM('YES', 'NO') NOT NULL,
    has_children ENUM('YES', 'NO') NOT NULL,
    has_other_pets ENUM('YES', 'NO') NOT NULL,
    UNIQUE (user_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- ------------------------------

CREATE TABLE recommendation_history (
    recommendation_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    breed_id INT NOT NULL,
    recommendation_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    reason TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (breed_id) REFERENCES breed(breed_id)
);

-- ============================================================
-- DATA INSERTION
-- ============================================================

INSERT INTO pet_category (category_name, description, category_image)
VALUES
('Dog', 'Domestic dogs for companionship and security', 'dog.jpg'),
('Cat', 'House cats for home pets', 'cat.jpg'),
('Bird', 'Pet birds like parrots and pigeons', 'bird.jpg'),
('Rabbit', 'Small friendly rabbits', 'rabbit.jpg'),
('Fish', 'Aquarium fish pets', 'fish.jpg');

-- ----------------------

INSERT INTO users (full_name, email, password_hash, phone, city, role)
VALUES
('Sowmiya', 'sowmiya@gmail.com', 'pass123', '9876543210', 'Chennai', 'ADMIN'),
('Kalisri', 'kalisri@gmail.com', 'pass123', '9876500001', 'Madurai', 'USER'),
('Thanish', 'thanish@gmail.com', 'pass123', '9876500002', 'Trichy', 'USER'),
('Karthik', 'karthik@gmail.com', 'pass123', '9876500003', 'Coimbatore', 'USER'),
('Murugan', 'murugan@gmail.com', 'pass123', '9876500004', 'Chennai', 'USER'),
('Rahul', 'rahul@gmail.com', 'pass123', '9876500005', 'Salem', 'USER'),
('Dev', 'dev@gmail.com', 'pass123', '9876500006', 'Erode', 'USER'),
('Jamal', 'jamal@gmail.com', 'pass123', '9876500007', 'Madurai', 'USER'),
('Varahi', 'varahi@gmail.com', 'pass123', '9876500008', 'Chennai', 'USER'),
('Sai', 'sai@gmail.com', 'pass123', '9876500009', 'Tirunelveli', 'USER');

-- ------------------------------

INSERT INTO breed
(category_id, breed_name, temperament, climate_suitability,
 suitable_for_first_time_owner, apartment_friendly,
 good_with_children, good_with_other_pets,
 min_price, max_price, estimated_monthly_cost,
 breed_image, min_lifespan_years, max_lifespan_years)
VALUES
(1,'Labrador Retriever','Friendly and Intelligent','ALL','YES','YES','YES','YES',20000,45000,3500,'labrador.jpg',10,12),
(1,'German Shepherd','Loyal and Courageous','ALL','YES','NO','YES','YES',25000,50000,4500,'german_shepherd.jpg',9,13),
(1,'Golden Retriever','Gentle and Friendly','ALL','YES','YES','YES','YES',30000,60000,5000,'golden_retriever.jpg',10,12),
(1,'Pug','Playful and Loving','HOT','YES','YES','YES','YES',15000,30000,2500,'pug.jpg',12,15),
(1,'Siberian Husky','Energetic and Friendly','COLD','NO','NO','YES','YES',35000,70000,6000,'husky.jpg',10,14),
(2,'Persian Cat','Calm and Quiet','ALL','YES','YES','YES','YES',18000,40000,2500,'persian.jpg',12,17),
(2,'Siamese Cat','Active and Vocal','HOT','YES','YES','YES','YES',15000,35000,2200,'siamese.jpg',11,15),
(2,'Maine Coon','Gentle Giant','COLD','YES','YES','YES','YES',30000,60000,3500,'maine_coon.jpg',12,15),
(3,'African Grey Parrot','Highly Intelligent','HOT','NO','YES','YES','NO',25000,50000,1800,'african_grey.jpg',40,60),
(3,'Cockatiel','Friendly and Social','ALL','YES','YES','YES','YES',5000,12000,1000,'cockatiel.jpg',15,20),
(3,'Budgerigar','Playful and Active','ALL','YES','YES','YES','YES',800,3000,500,'budgie.jpg',7,10),
(4,'Holland Lop Rabbit','Gentle and Friendly','ALL','YES','YES','YES','YES',4000,10000,1200,'holland_lop.jpg',7,12),
(4,'Lionhead Rabbit','Curious and Playful','ALL','YES','YES','YES','YES',5000,12000,1300,'lionhead.jpg',8,10),
(5,'Goldfish','Peaceful','ALL','YES','YES','YES','YES',100,500,300,'goldfish.jpg',8,15),
(5,'Betta Fish','Territorial','HOT','YES','YES','NO','NO',300,1500,400,'betta.jpg',3,5);

-- ----------------------

INSERT INTO breed_care
(breed_id, recommended_food, foods_to_avoid, grooming_guide, bathing_frequency, maintenance_tips, reference_link)
VALUES
(1,'Chicken, rice, vegetables, dog food','Chocolate, onion, grapes','Brush twice a week','Once every 2 weeks','Provide daily exercise and clean drinking water','https://example.com/labrador'),
(2,'High-protein dog food, chicken','Chocolate, garlic, onion','Brush 3 times a week','Every 2 weeks','Needs regular training and exercise','https://example.com/germanshepherd'),
(3,'Chicken, fish, vegetables','Chocolate, grapes, onion','Brush twice a week','Once every 3 weeks','Friendly family dog, daily walk recommended','https://example.com/goldenretriever'),
(4,'Soft dog food, chicken','Chocolate, fatty food','Brush weekly','Once a month','Avoid overfeeding due to obesity risk','https://example.com/pug'),
(5,'Protein-rich food, fish','Chocolate, cooked bones','Brush 3 times a week','Every 3 weeks','Suitable for cooler climates','https://example.com/husky'),
(6,'Cat food, fish, chicken','Chocolate, onion, milk','Brush daily','Once a month','Keep coat clean to avoid tangles','https://example.com/persian'),
(7,'Dry and wet cat food','Chocolate, onion','Brush weekly','Once a month','Provide toys and mental stimulation','https://example.com/siamese'),
(8,'High-quality cat food','Chocolate, onion','Brush twice a week','Once a month','Needs spacious environment','https://example.com/mainecoon'),
(9,'Seeds, fruits, vegetables','Avocado, chocolate','Clean feathers regularly','Mist bath weekly','Provide toys for mental stimulation','https://example.com/africangrey'),
(10,'Seeds, pellets, vegetables','Chocolate, avocado','Minimal grooming','Mist bath weekly','Needs social interaction','https://example.com/cockatiel'),
(11,'Seeds, vegetables','Chocolate, avocado','Minimal grooming','Mist bath weekly','Keep cage clean','https://example.com/budgie'),
(12,'Hay, rabbit pellets, vegetables','Chocolate, potato','Brush weekly','Only when necessary','Provide enough space to hop','https://example.com/hollandlop'),
(13,'Hay, leafy vegetables','Chocolate, onion','Brush twice a week','Only when necessary','Regular nail trimming','https://example.com/lionhead'),
(14,'Fish flakes, pellets','Bread, chocolate','Clean aquarium weekly','Not applicable','Maintain water quality','https://example.com/goldfish'),
(15,'Betta pellets','Bread, chocolate','No grooming required','Not applicable','Keep alone in clean water','https://example.com/betta');

-- -----------------------------

INSERT INTO vaccination_guide
(breed_id, vaccine_name, first_dose_age, booster_period, notes)
VALUES
(1,'DHPP','6 Weeks','Every 1 Year','Core vaccine for puppies'),
(2,'Rabies','12 Weeks','Every 1 Year','Mandatory vaccine'),
(3,'DHPP','6 Weeks','Every 1 Year','Protects against common diseases'),
(4,'Rabies','12 Weeks','Every 1 Year','Government recommended'),
(5,'Bordetella','8 Weeks','Every 1 Year','Protects against kennel cough'),
(6,'FVRCP','8 Weeks','Every 1 Year','Core vaccine for cats'),
(7,'Rabies','12 Weeks','Every 1 Year','Mandatory for cats'),
(8,'FVRCP','8 Weeks','Every 1 Year','Prevents viral infections'),
(9,'Polyomavirus','8 Weeks','As advised','For parrots'),
(10,'Polyomavirus','8 Weeks','As advised','Recommended for cockatiels'),
(11,'Polyomavirus','8 Weeks','As advised','Recommended for budgies'),
(12,'Rabbit Hemorrhagic Disease','6 Weeks','Annual','Essential vaccine'),
(13,'Rabbit Hemorrhagic Disease','6 Weeks','Annual','Prevents viral disease'),
(14,'Water Quality Check','Monthly','Monthly','Maintain healthy aquarium'),
(15,'Water Quality Check','Monthly','Monthly','Regular tank maintenance');

-- ----------------------------

INSERT INTO pet_profile
(user_id, breed_id, pet_name, pet_photo, gender, age_months, weight, adoption_date)
VALUES
(1,1,'Bruno','bruno.jpg','MALE',24,28.5,'2024-01-15'),
(2,6,'Bella','bella.jpg','FEMALE',18,4.2,'2024-03-10'),
(3,2,'Rocky','rocky.jpg','MALE',30,34.8,'2023-09-20'),
(4,10,'Coco','coco.jpg','UNKNOWN',12,0.12,'2025-01-08'),
(5,5,'Max','max.jpg','MALE',20,25.6,'2024-02-18'),
(6,4,'Charlie','charlie.jpg','MALE',36,8.1,'2023-05-12'),
(7,7,'Luna','luna.jpg','FEMALE',14,3.8,'2024-08-05'),
(8,12,'Snowy','snowy.jpg','FEMALE',10,1.6,'2025-02-01'),
(9,14,'Goldie','goldie.jpg','UNKNOWN',8,0.20,'2025-03-15'),
(10,15,'Blue','blue.jpg','MALE',6,0.08,'2025-04-10');

-- ---------------------

INSERT INTO vaccination_record
(pet_id, vaccine_name, vaccination_date, next_due_date, status)
VALUES
(1, 'DHPP', '2025-01-15', '2026-01-15', 'COMPLETED'),
(2, 'FVRCP', '2025-02-10', '2026-02-10', 'COMPLETED'),
(3, 'Rabies', '2025-03-05', '2026-03-05', 'COMPLETED'),
(4, 'Polyomavirus', '2025-04-12', '2026-04-12', 'COMPLETED'),
(5, 'Rabies', '2025-02-20', '2026-02-20', 'COMPLETED'),
(6, 'DHPP', '2024-12-15', '2025-12-15', 'PENDING'),
(7, 'Rabies', '2025-01-25', '2026-01-25', 'COMPLETED'),
(8, 'Rabbit Hemorrhagic Disease', '2025-03-01', '2026-03-01', 'COMPLETED'),
(9, 'Water Quality Check', '2025-06-01', '2025-07-01', 'PENDING'),
(10, 'Water Quality Check', '2025-06-10', '2025-07-10', 'PENDING');

-- ---------------------

INSERT INTO grooming_checklist
(pet_id, grooming_date, next_due_date, remarks)
VALUES
(1, '2025-06-10', '2025-07-10', 'Regular brushing and nail trimming'),
(2, '2025-06-12', '2025-07-12', 'Coat brushed and ears cleaned'),
(3, '2025-06-15', '2025-07-15', 'Full grooming completed'),
(4, '2025-06-18', '2025-07-18', 'Feathers cleaned and cage sanitized'),
(5, '2025-06-20', '2025-07-20', 'Bath and coat brushing completed'),
(6, '2025-06-08', '2025-07-08', 'Nail trimming completed'),
(7, '2025-06-11', '2025-07-11', 'Hair brushing completed'),
(8, '2025-06-14', '2025-07-14', 'Fur cleaned and nails checked'),
(9, '2025-06-05', '2025-07-05', 'Aquarium cleaned'),
(10, '2025-06-07', '2025-07-07', 'Fish tank water changed');

-- -----------------------

INSERT INTO daily_care_checklist
(pet_id, task_name, task_date, status)
VALUES
(1,'Morning Walk','2025-06-30','DONE'),
(1,'Feed Pet','2025-06-30','DONE'),
(2,'Feed Pet','2025-06-30','DONE'),
(2,'Brush Fur','2025-06-30','PENDING'),
(3,'Morning Walk','2025-06-30','DONE'),
(3,'Clean Water Bowl','2025-06-30','DONE'),
(4,'Clean Cage','2025-06-30','DONE'),
(4,'Feed Bird','2025-06-30','DONE'),
(5,'Morning Walk','2025-06-30','PENDING'),
(5,'Feed Pet','2025-06-30','DONE'),
(6,'Feed Pet','2025-06-30','DONE'),
(6,'Brush Fur','2025-06-30','DONE'),
(7,'Feed Pet','2025-06-30','DONE'),
(7,'Clean Litter Box','2025-06-30','PENDING'),
(8,'Feed Rabbit','2025-06-30','DONE'),
(8,'Clean Cage','2025-06-30','DONE'),
(9,'Feed Fish','2025-06-30','DONE'),
(9,'Check Water Quality','2025-06-30','PENDING'),
(10,'Feed Fish','2025-06-30','DONE'),
(10,'Clean Aquarium','2025-06-30','DONE');

-- ---------------------

INSERT INTO user_preferences
(user_id, house_type, budget, climate, first_time_owner, has_children, has_other_pets)
VALUES
(1,'HOUSE','HIGH','HOT','NO','YES','YES'),
(2,'APARTMENT','MEDIUM','HOT','YES','NO','NO'),
(3,'HOUSE','HIGH','ALL','NO','YES','YES'),
(4,'APARTMENT','LOW','HOT','YES','NO','NO'),
(5,'HOUSE','HIGH','COLD','NO','YES','YES'),
(6,'APARTMENT','LOW','HOT','YES','YES','NO'),
(7,'HOUSE','MEDIUM','ALL','YES','NO','YES'),
(8,'HOUSE','LOW','HOT','YES','YES','NO'),
(9,'APARTMENT','LOW','ALL','YES','NO','NO'),
(10,'APARTMENT','MEDIUM','HOT','YES','NO','NO');

-- --------------------

INSERT INTO recommendation_history
(user_id, breed_id, reason)
VALUES
(1,1,'Suitable for experienced owner with high budget'),
(2,6,'Apartment friendly and ideal for first-time owner'),
(3,2,'Good for active family with children'),
(4,10,'Low maintenance pet for apartment living'),
(5,5,'Suitable for spacious house in cooler climate'),
(6,4,'Affordable breed for beginner owner'),
(7,7,'Friendly breed for homes with other pets'),
(8,12,'Easy to care rabbit for family'),
(9,14,'Low budget aquatic pet'),
(10,15,'Easy beginner fish for apartment');

-- ============================================================
-- QUERIES
-- ============================================================

SELECT * FROM users;

SELECT * FROM users
WHERE role = 'ADMIN';

SELECT * FROM users
WHERE role = 'USER';

SELECT * FROM pet_category;

SELECT * FROM breed;

SELECT b.breed_name
FROM breed b
INNER JOIN pet_category p
ON b.category_id = p.category_id
WHERE p.category_name = 'Dog';

SELECT breed_name
FROM breed
WHERE suitable_for_first_time_owner = 'YES';

SELECT breed_name
FROM breed
WHERE apartment_friendly = 'YES';

SELECT breed_name,
       min_price,
       max_price
FROM breed
WHERE max_price > 50000;

SELECT pet_name,
       age_months
FROM pet_profile
WHERE age_months > 12;

SELECT city FROM users;

SELECT DISTINCT city FROM users;

SELECT * FROM users
WHERE full_name LIKE 'S%';

SELECT * FROM users
WHERE full_name LIKE '%a';

SELECT breed_name, max_price
FROM breed
WHERE max_price BETWEEN 20000 AND 60000;

SELECT * FROM users
WHERE city IN ('Chennai','Madurai');

SELECT breed_name,
       max_price
FROM breed
ORDER BY max_price ASC;

SELECT breed_name,
       max_price
FROM breed
ORDER BY max_price DESC;

SELECT * FROM pet_profile
WHERE gender = 'FEMALE';

-- ------ Aggregate Functions ---------

SELECT COUNT(*) AS Total_Users
FROM users;

SELECT COUNT(*) AS Total_Categories
FROM pet_category;

SELECT COUNT(*) AS Total_Breeds
FROM breed;

SELECT SUM(estimated_monthly_cost) AS Total_Monthly_Cost
FROM breed;

SELECT AVG(max_price) AS Average_Breed_Price
FROM breed;

SELECT MIN(min_price) AS Lowest_Price
FROM breed;

SELECT MAX(max_price) AS Highest_Price
FROM breed;

SELECT COUNT(*) AS Chennai_Users FROM users
WHERE city = 'Chennai';

SELECT AVG(weight) AS Average_Male_Pet_Weight FROM pet_profile
WHERE gender = 'MALE';

SELECT MAX(b.estimated_monthly_cost) AS Highest_Dog_Maintenance
FROM breed b
INNER JOIN pet_category p
ON b.category_id = p.category_id
WHERE p.category_name = 'Dog';

SELECT AVG(weight) AS Average_Pet_Weight
FROM pet_profile;

SELECT p.category_name,
       COUNT(b.breed_id) AS Total_Breeds
FROM pet_category p
INNER JOIN breed b
ON p.category_id = b.category_id
GROUP BY p.category_name;

-- ------------ Number of Pets Owned by Each User ----------
SELECT u.full_name,
       COUNT(pp.pet_id) AS Total_Pets
FROM users u
INNER JOIN pet_profile pp
ON u.user_id = pp.user_id
GROUP BY u.full_name;

-- --------- Average Maximum Price by Category --------
SELECT p.category_name,
       AVG(b.max_price) AS Average_Price
FROM pet_category p
INNER JOIN breed b
ON p.category_id = b.category_id
GROUP BY p.category_name;

-- ------ Highest Monthly Cost by Category ---------
SELECT p.category_name,
       MAX(b.estimated_monthly_cost) AS Highest_Monthly_Cost
FROM pet_category p
INNER JOIN breed b
ON p.category_id = b.category_id
GROUP BY p.category_name;

-- ------ Number of Vaccination Records by Status ---------
SELECT status,
       COUNT(*) AS Total_Records
FROM vaccination_record
GROUP BY status;

-- ------ Show Categories Having More Than 2 Breeds  --------
SELECT p.category_name,
       COUNT(b.breed_id) AS Total_Breeds
FROM pet_category p
INNER JOIN breed b
ON p.category_id = b.category_id
GROUP BY p.category_name
HAVING COUNT(b.breed_id) > 2;

-- --------- Show Users Owning at Least 1 Pet ----------
SELECT u.full_name,
       COUNT(pp.pet_id) AS Total_Pets
FROM users u
INNER JOIN pet_profile pp
ON u.user_id = pp.user_id
GROUP BY u.full_name
HAVING COUNT(pp.pet_id) >= 1;

-- ------------ Categories with Average Breed Price Above ₹40,000 -----------
SELECT p.category_name,
       AVG(b.max_price) AS Average_Price
FROM pet_category p
INNER JOIN breed b
ON p.category_id = b.category_id
GROUP BY p.category_name
HAVING AVG(b.max_price) > 40000;

-- -----------------
SELECT u.full_name,
       p.pet_name
FROM users u
INNER JOIN pet_profile p
ON u.user_id = p.user_id;

-- ---------------------
SELECT
    u.full_name,
    p.pet_name,
    b.breed_name,
    c.category_name
FROM users u
INNER JOIN pet_profile p
    ON u.user_id = p.user_id
INNER JOIN breed b
    ON p.breed_id = b.breed_id
INNER JOIN pet_category c
    ON b.category_id = c.category_id;

-- ----------------------
SELECT u.full_name,
       p.pet_name
FROM users u
LEFT JOIN pet_profile p
ON u.user_id = p.user_id;

-- ---------------
SELECT
    u.user_id,
    u.full_name,
    p.pet_name
FROM users u
LEFT JOIN pet_profile p
ON u.user_id = p.user_id;

-- -------------
INSERT INTO users
(full_name, email, password_hash, phone, city, role)
VALUES
('Demo User','demo@gmail.com','pass123','9999999999','Chennai','USER');

DELETE FROM users
WHERE email = 'demo@gmail.com';

-- --------------
SELECT
    b.breed_name,
    bc.recommended_food,
    bc.grooming_guide
FROM breed b
LEFT JOIN breed_care bc
ON b.breed_id = bc.breed_id;

-- --------- RIGHT JOIN -----------
SELECT
    u.full_name,
    p.pet_name
FROM pet_profile p
RIGHT JOIN users u
ON p.user_id = u.user_id;

-- ------ Users and Their Recommendations ---------
SELECT
    u.full_name,
    b.breed_name,
    r.recommendation_date
FROM recommendation_history r
INNER JOIN users u
ON r.user_id = u.user_id
INNER JOIN breed b
ON r.breed_id = b.breed_id;

-- --- Pet Vaccination Details -----
SELECT
    p.pet_name,
    vr.vaccine_name,
    vr.vaccination_date,
    vr.status
FROM pet_profile p
INNER JOIN vaccination_record vr
ON p.pet_id = vr.pet_id;

-- --- Complete Pet Information ----
SELECT
    u.full_name,
    p.pet_name,
    b.breed_name,
    c.category_name,
    p.age_months,
    p.weight
FROM users u
INNER JOIN pet_profile p
ON u.user_id = p.user_id
INNER JOIN breed b
ON p.breed_id = b.breed_id
INNER JOIN pet_category c
ON b.category_id = c.category_id;

-- --- Daily Care Tasks ----
SELECT
    p.pet_name,
    d.task_name,
    d.task_date,
    d.status
FROM pet_profile p
INNER JOIN daily_care_checklist d
ON p.pet_id = d.pet_id;

-- --- Grooming Details -----
SELECT
    p.pet_name,
    g.grooming_date,
    g.next_due_date
FROM pet_profile p
INNER JOIN grooming_checklist g
ON p.pet_id = g.pet_id;

-- ------ Category-wise Breed Count ----------
SELECT
    c.category_name,
    COUNT(b.breed_id) AS total_breeds
FROM pet_category c
INNER JOIN breed b
ON c.category_id = b.category_id
GROUP BY c.category_name;

-- --------- User Preferences with Recommendations -------
SELECT
    u.full_name,
    up.house_type,
    up.budget,
    b.breed_name
FROM users u
INNER JOIN user_preferences up
ON u.user_id = up.user_id
INNER JOIN recommendation_history r
ON u.user_id = r.user_id
INNER JOIN breed b
ON r.breed_id = b.breed_id;

-- ------ Pet Count by Breed -------
SELECT
    b.breed_name,
    COUNT(p.pet_id) AS total_pets
FROM breed b
INNER JOIN pet_profile p
ON b.breed_id = p.breed_id
GROUP BY b.breed_name;

-- ============================================================
-- STORED PROCEDURES
-- ============================================================

-- --------- Procedure 1: Get pet details by user ----------
DELIMITER $$

CREATE PROCEDURE GetPetDetailsByUser(IN p_user_id INT)
BEGIN
    SELECT
        p.pet_name,
        b.breed_name,
        c.category_name,
        p.age_months,
        p.weight
    FROM pet_profile p
    INNER JOIN breed b
        ON p.breed_id = b.breed_id
    INNER JOIN pet_category c
        ON b.category_id = c.category_id
    WHERE p.user_id = p_user_id;
END $$

DELIMITER ;

CALL GetPetDetailsByUser(1);

-- ------ Procedure 2: Get vaccination history for a pet --------
DELIMITER $$

CREATE PROCEDURE GetVaccinationHistory(IN p_pet_id INT)
BEGIN
    SELECT
        p.pet_name,
        vr.vaccine_name,
        vr.vaccination_date,
        vr.next_due_date,
        vr.status
    FROM pet_profile p
    INNER JOIN vaccination_record vr
        ON p.pet_id = vr.pet_id
    WHERE p.pet_id = p_pet_id;
END $$

DELIMITER ;

CALL GetVaccinationHistory(1);

-- ============================================================
-- FUNCTIONS
-- ============================================================

-- ------- Function 1: Total pets owned by a user ----------
DELIMITER $$

CREATE FUNCTION TotalPets(userId INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;

    SELECT COUNT(*)
    INTO total
    FROM pet_profile
    WHERE user_id = userId;

    RETURN total;
END $$

DELIMITER ;

SELECT TotalPets(1);

-- ----------- Function 2: Average pet weight (overall) ------
DELIMITER $$

CREATE FUNCTION AveragePetWeight()
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE avgWeight DECIMAL(5,2);

    SELECT AVG(weight)
    INTO avgWeight
    FROM pet_profile;

    RETURN avgWeight;
END $$

DELIMITER ;

SELECT AveragePetWeight();

-- ============================================================
-- SCENARIO-BASED QUERIES
-- ============================================================

-- Scenario 1: Display all pets owned by a specific user (Sowmiya)
SELECT u.full_name, p.pet_name
FROM users u
INNER JOIN pet_profile p
ON u.user_id = p.user_id
WHERE u.full_name = 'Sowmiya';

-- Scenario 2: Display all pets belonging to the Dog category
SELECT p.pet_name, b.breed_name
FROM pet_profile p
INNER JOIN breed b
ON p.breed_id = b.breed_id
INNER JOIN pet_category c
ON b.category_id = c.category_id
WHERE c.category_name = 'Dog';

-- Scenario 3: Display pets with overdue vaccinations
UPDATE vaccination_record
SET status = 'OVERDUE'
WHERE record_id = 6;

SELECT p.pet_name, v.vaccine_name, v.next_due_date
FROM pet_profile p
INNER JOIN vaccination_record v
ON p.pet_id = v.pet_id
WHERE v.status = 'OVERDUE';

-- Scenario 4: Display all users from Chennai
SELECT *
FROM users
WHERE city = 'Chennai';

-- Scenario 5: Display breeds suitable for first-time owners
SELECT breed_name
FROM breed
WHERE suitable_for_first_time_owner = 'YES';

-- Scenario 6: Display all pets weighing more than 10 kg
SELECT pet_name, weight
FROM pet_profile
WHERE weight > 10;

-- Scenario 7: Count the number of pets in each category
SELECT c.category_name, COUNT(p.pet_id) AS total_pets
FROM pet_profile p
INNER JOIN breed b
ON p.breed_id = b.breed_id
INNER JOIN pet_category c
ON b.category_id = c.category_id
GROUP BY c.category_name;

-- Scenario 8: Display all completed vaccinations
SELECT *
FROM vaccination_record
WHERE status = 'COMPLETED';

-- Scenario 9: Display pets whose grooming is due before today
SELECT p.pet_name, g.next_due_date
FROM pet_profile p
INNER JOIN grooming_checklist g
ON p.pet_id = g.pet_id
WHERE g.next_due_date < CURDATE();

-- Scenario 10: Display pending daily care tasks
SELECT p.pet_name, d.task_name
FROM pet_profile p
INNER JOIN daily_care_checklist d
ON p.pet_id = d.pet_id
WHERE d.status = 'PENDING';

-- Scenario 11: Display users and their recommended breeds
SELECT u.full_name, b.breed_name
FROM recommendation_history r
INNER JOIN users u
ON r.user_id = u.user_id
INNER JOIN breed b
ON r.breed_id = b.breed_id;

-- Scenario 12: Display breeds with monthly maintenance cost above ₹3000
SELECT breed_name, estimated_monthly_cost
FROM breed
WHERE estimated_monthly_cost > 3000;

-- Scenario 13: Find the average pet weight
SELECT AVG(weight) AS average_weight
FROM pet_profile;

-- Scenario 14: Display users who own more than one pet
SELECT u.full_name, COUNT(p.pet_id) AS total_pets
FROM users u
INNER JOIN pet_profile p
ON u.user_id = p.user_id
GROUP BY u.user_id, u.full_name
HAVING COUNT(p.pet_id) > 1;

-- Scenario 15: Display complete pet information (Owner, Pet, Breed, Category)
SELECT
    u.full_name,
    p.pet_name,
    b.breed_name,
    c.category_name
FROM users u
INNER JOIN pet_profile p
ON u.user_id = p.user_id
INNER JOIN breed b
ON p.breed_id = b.breed_id
INNER JOIN pet_category c
ON b.category_id = c.category_id;

-- ============================================================
-- TRIGGER TEST 
-- ============================================================

-- test valid --
INSERT INTO pet_profile
(user_id, breed_id, pet_name, gender, age_months, weight, adoption_date)
VALUES
(1,1,'Test Pet','MALE',12,10.5,'2025-01-01');

-- invalid: should raise "Pet age cannot be negative" --
INSERT INTO pet_profile
(user_id, breed_id, pet_name, gender, age_months, weight, adoption_date)
VALUES
(1,1,'Wrong Pet','MALE',-5,10.5,'2025-01-01');
