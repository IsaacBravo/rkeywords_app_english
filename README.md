---
# Keyword Generator App

This Shiny application generates keywords based on a user-provided boolean search string and a corpus file. It leverages various R packages such as udpipe, cleanNLP, and quanteda to process the corpus and create new keywords. The app is based on the R package (rKeywords) developed by Sean-Kelly Palick [https://github.com/seankellyhp](https://github.com/seankellyhp/rKeywords).

### Installation
1. Clone this repository:

```sh
git clone https://github.com/IsaacBravo/rkeywords_app_english.git
cd rkeywords_app_english
```

2. Install the required R packages:

```R
install.packages(c("shiny", "bslib", "udpipe", "cleanNLP", "quanteda", "quanteda.textstats", "shinybusy", "spacyr"))
```

### Usage
3. Run the Shiny app:

```R
shiny::runApp()
```

4. In the sidebar, provide the following inputs:

* **Search String:** Enter your boolean search string (e.g., Immigrant* OR migrant* OR asylum seeker* OR visa*).
* **Corpus File:** Upload your corpus file in .rds format.
* **GloVe Model:** Select the pre-trained GloVe model to use. (NOTE: You need to download the models from this website: https://nlp.stanford.edu/projects/glove/")
* **Number of Candidates:** Choose the number of candidate keywords.
* **Number of Keywords for Query:** Choose the number of keywords to include in the final query.
* Click Process Keywords to generate keywords.
  
5. View the results in the "Results" section, which includes:

* **Seed Words:** The initial list of keywords derived from the boolean search string.
* **Generated Keywords:** The newly generated keywords based on the corpus and model.
* **Final Query:** The formatted query string.
