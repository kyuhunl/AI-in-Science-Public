# AI in Science: Closing the Experience Gap? The Impact of AlphaFold on Life Scientists’ Productivity
## Overview
This is a doctoral research project exploring the impact of new AI tools in a scientific domain on scientific productivity. Looking at life scientists who start using AlphaFold, I find a positive association between using AlphaFold for the first time (adoption) and post-adoption monthly publication rate. The correlation is stronger for scientists in their early stage careers.
## Research Problems
- Despite the increasing integration of AI in the process of scientific discovery, its effects on research outcomes, processes, and implications for researchers remain underexplored.
- Accurately identifying AI usage (not development) in patents, papers, etc. is difficult if not impossible (WIP)
## Data Sources
[OpenAlex](https://openalex.org/): Catalogue of scholarly works
[Clarivate Journal Citation Reports](https://clarivate.com/academia-government/scientific-and-academic-research/research-funding-analytics/journal-citation-reports/): Journal quality measures such as impact factors (IF)
[S2ORC](https://github.com/allenai/s2orc): Full-text dataset for Open Access research
## Tools used
Python: Data mining, cleaning, and wrangling
SQLite3: Database maintenance and querying
STATA: Two-Way Fixed Effects regression and [Callaway & Sant'anna's (2021)](https://www.sciencedirect.com/science/article/abs/pii/S0304407620303948) DID specification
[GROBID](https://github.com/kermitt2/grobid): Extracting text data from PDFs (WIP)
OpenAI API: Parsing relevant sections from full-text (WIP)
## To-dos
- Identify mechanisms and explore impact on other career outcomes: merging the OpenAlex data with researcher-level dataset such as LinkedIn profiles, ProQuest Dissertations & Theses, and grant data from the National Science Foundation
- Look at changes in research direction after adopting AI
- Use AlphaFold open release as treatment rather than individual use, compare between fields differently affected by AF
- Develop generalized method for identifying AI use (WIP): sourcing PDFs or full-texts from journal APIs, extract and process text, identify AI use with LLMs
