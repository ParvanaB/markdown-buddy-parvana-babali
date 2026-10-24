AI Assistance Declaration: I used ChatGPT (GPT-6, October 24, 2026) to draft and organize documentation. See Appendix.md for prompts. I must personally verify the R code and calculations before submission.

# Synthetic Student Performance Analysis in R

**Author:** Parvana Babali  
**Student number:** 664430071  
**Course:** BDA400 — Data Science Tools and Techniques  
**Date:** October 24, 2026

## Overview

This educational project documents a reproducible R workflow using a **synthetic** student-performance dataset. The R script creates six fictional records, prints numeric summaries, and plots study hours against scores. No real student information is used.

## Project Objectives

- Document an R project using Markdown and R Markdown.
- Explain inputs, transformations, and outputs.
- Review AI-assisted documentation against the actual code.

## Repository Structure

```text
README.md
student_analysis.R
student_analysis_documentation.Rmd
Reflection.md
Appendix.md
```

## Requirements and Installation

Install R and optionally RStudio or Posit Cloud. The analysis uses **base R only**. To render the R Markdown report, install:

```r
install.packages("rmarkdown")
```

## Synthetic Data and Inputs

The script generates six fictional records with `student_id`, `study_hours`, and `score`. No external files are required.

## Example Usage

Run the script in R from the repository directory:

```r
source("student_analysis.R")
```

Render the R Markdown report:

```r
rmarkdown::render("student_analysis_documentation.Rmd")
```

## Outputs

The script prints the fictional records and numerical summaries and produces a scatter plot. The sample is too small to support statistical generalizations or causal claims.

## Validation and Limitations

**GitHub publication:** All five files uploaded to the ParvanaB repository on October 24, 2026; GitHub file contents verified through the connected GitHub API.

**Still to verify manually:** Preview Markdown on GitHub, run the R script in RStudio/Posit Cloud, render the R Markdown document, and check the outputs. Uploading files does not establish that R code executed successfully.

## License

Educational example for BDA400 coursework. No open-source license has been granted.

## AI Assistance Disclosure

ChatGPT (GPT-6) assisted with the outline, wording, R Markdown formatting, and reflection drafting. Actual and illustrative prompts are distinguished in `Appendix.md`. The student is responsible for independently reviewing and verifying the final work.
