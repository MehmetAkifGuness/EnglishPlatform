# Learning engine: current baseline

The current engine is deterministic and rule-based. A fixed assessment records per-topic attempts and correct answers. Exercise answers add further evidence. `UserTopicProgress` derives a mastery score and confidence and schedules review after one, three, or seven days according to mastery bands. `LearningPathService` prioritizes due topics below the mastery threshold, then the lowest-evidence topic with an available lesson.

These values are provisional indicators, not certain diagnoses. The current approach does not model uncertainty statistically, prerequisites, recurring error categories, objectives, or alternative algorithms. The assessment has two questions per topic, so its level estimate is especially limited.

Next research steps: validate the content and scoring with labeled learner data, add deterministic decision tests for edge cases, compare this baseline with a documented BKT implementation, and version/log recommendation decisions before changing the model.
