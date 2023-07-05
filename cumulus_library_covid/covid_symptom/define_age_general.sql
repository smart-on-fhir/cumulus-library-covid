CREATE OR REPLACE VIEW covid_symptom__define_age AS
SELECT
    t.age,
    t.age_group
FROM
    (
        VALUES
        (0, '<=5'),
        (1, '<=5'),
        (2, '<=5'),
        (3, '<=5'),
        (4, '<=5'),
        (5, '<=5'),

        (6, '6-11'),
        (7, '6-11'),
        (8, '6-11'),
        (9, '6-11'),
        (10, '6-11'),
        (11, '6-11'),

        (12, '12-18'),
        (13, '12-18'),
        (14, '12-18'),
        (15, '12-18'),
        (16, '12-18'),
        (17, '12-18'),
        (18, '12-18'),

        (19, '19-29'),
        (20, '19-29'),
        (21, '19-29'),
        (22, '19-29'),
        (23, '19-29'),
        (24, '19-29'),
        (25, '19-29'),
        (26, '19-29'),
        (27, '19-29'),
        (28, '19-29'),
        (29, '19-29'),

        (30, '30-39'),
        (31, '30-39'),
        (32, '30-39'),
        (33, '30-39'),
        (34, '30-39'),
        (35, '30-39'),
        (36, '30-39'),
        (37, '30-39'),
        (38, '30-39'),
        (39, '30-39'),

        (40, '40-49'),
        (41, '40-49'),
        (42, '40-49'),
        (43, '40-49'),
        (44, '40-49'),
        (45, '40-49'),
        (46, '40-49'),
        (47, '40-49'),
        (48, '40-49'),
        (49, '40-49'),

        (50, '50-59'),
        (51, '50-59'),
        (52, '50-59'),
        (53, '50-59'),
        (54, '50-59'),
        (55, '50-59'),
        (56, '50-59'),
        (57, '50-59'),
        (58, '50-59'),
        (59, '50-59'),

        (60, '60-69'),
        (61, '60-69'),
        (62, '60-69'),
        (63, '60-69'),
        (64, '60-69'),
        (65, '60-69'),
        (66, '60-69'),
        (67, '60-69'),
        (68, '60-69'),
        (69, '60-69'),

        (70, '70-79'),
        (71, '70-79'),
        (72, '70-79'),
        (73, '70-79'),
        (74, '70-79'),
        (75, '70-79'),
        (76, '70-79'),
        (77, '70-79'),
        (78, '70-79'),
        (79, '70-79'),

        (80, '80-89'),
        (81, '80-89'),
        (82, '80-89'),
        (83, '80-89'),
        (84, '80-89'),
        (85, '80-89'),
        (86, '80-89'),
        (87, '80-89'),
        (88, '80-89'),
        (89, '80-89'),

        (90, '>=90'),
        (91, '>=90'),
        (92, '>=90'),
        (93, '>=90'),
        (94, '>=90'),
        (95, '>=90'),
        (96, '>=90'),
        (97, '>=90'),
        (98, '>=90'),
        (99, '>=90'),
        (100, '>=90'),
        (101, '>=90'),
        (102, '>=90'),
        (103, '>=90'),
        (104, '>=90'),
        (105, '>=90'),
        (106, '>=90'),
        (107, '>=90'),
        (108, '>=90'),
        (109, '>=90'),
        (110, '>=90')
    ) AS t (age, age_group);
