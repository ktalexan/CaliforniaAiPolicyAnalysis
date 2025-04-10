#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Policy Analysis R Data Processing #
# Project Functions ####
# v 1.0, March 2025
# Dr. Kostas Alexandridis, GISP
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Empty the R environment before running the code
rm(list = ls())

# Load the required libraries from libraries.json and apply them
library(jsonlite)
sapply(fromJSON(file.path(getwd(), "metadata", "libraries.json")), require, character.only = TRUE)

# Set version
ver = 1.0

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 1. Metadata ####
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Define the global project settings by creating a function that returns a list of the project's metadata
projectMetadata <- function(prjComponent, prjPart) { # nolint: object_name_linter.
    
    # Set the project component
    if (prjComponent == "LC") {
        prjTitle = "OCEA Legislative Committee Analysis"
        prjYears = "2025-2026"
        startDate = "2024-12-02"
    } else if (prjComponent == "AI") {
        prjTitle = "AI Legislative Policy Analysis"
        prjYears = c("2011-2012","2013-2014","2015-2016","2017-2018","2019-2020","2021-2022","2023-2024","2025-2026")
        startDate = "2010-12-02"
    }
    
    # Set the title based on the part
    if (prjPart == 0) {
        prjStep = "Project Maintenance Operations"
    } else if (prjPart == 1) {
        prjStep = "Part 1: Preliminary Operations"
    } else if (prjPart == 2) {
        prjStep = "Part 2: Creating Bibliography Entries and Databases"
    } else if (prjPart == 3) {
        prjStep = "Part 3: Analysis Markdown Documents"
    } else if (prjPart == 4) {
        prjStep = "Part 4: Data Analysis and Visualization"
    }
    
    # create a new list
    data <- list(
        "name" = prjTitle,
        "title" = prjStep,
        "version" = glue("Version {ver}, {format(Sys.Date(), '%B %Y')}"),
        "author" = "Dr. Kostas Alexandridis, GISP",
        "projectYears" = prjYears,
        "startDate" = startDate,
        "endDate" = Sys.Date()
    )
    # Set this program's metadata
    cat("Project Global Settings:\n")
    print(glue("\r\tName: \t{data$name}\n\r\tTitle: \t{data$title} \n\r\tVersion: {data$version} \n\r\tAuthor: {data$author}\n"))
    cat("Data Dates:\n")
    # join the prjYears with commas
    prjYears = paste(data$projectYears, collapse = ", ")
    
    print(glue("\r\tStart Date: \t{data$startDate}\n\r\tEnd Date: \t{data$endDate}\n\r\tPeriods: \t{paste(data$projectYears, collapse = ', ')}"))
    # Return the data list
    return(data)
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 2. Directories ####
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Define the global directory settings using the following function that returns a list of the project's directories
projectDirectories <- function() {
    # Get the basic project directory on the OneDrive Documents directory
    setwd(file.path(Sys.getenv("OneDriveConsumer"), "Documents", "GitHub", "CaliforniaPolicyAnalysis"))
    # Create a new data list
    data <- list(
        "pathPrj" = getwd(),
        "pathAdmin" = file.path(getwd(), "admin"),
        "pathAnalysis" = file.path(getwd(), "analysis"),
        "pathData" = file.path(getwd(), "data"),
        "pathDataDocs" = file.path(getwd(), "data", "documents"),
        "pathDataMd" = file.path(getwd(), "data", "markdown"),
        "pathDataRis" = file.path(getwd(), "data", "ris"),
        "pathGraphics" = file.path(getwd(), "graphics"),
        "pathMetadata" = file.path(getwd(), "metadata"),
        "pathScripts" = file.path(getwd(), "scripts"),
        "pathScriptsR" = file.path(getwd(), "scripts", "R"),
        "pathScriptsPy" = file.path(getwd(), "scripts", "python"),
        "pathScriptsMd" = file.path(getwd(), "scripts", "markdown"),
        "pathScriptsRis" = file.path(getwd(), "scripts", "ris"),
        "pathNotebooks" = file.path(getwd(), "metadata", "notebooks")
    )
    # Print output in console
    cat("Directory Global Settings:\n")
    print(glue(
        "\nGeneral:",
        "\n\tDefault: \t{data$pathScriptsR}",
        "\n\tProject: \t{data$pathPrj}",
        "\nData: ",
        "\n\tMain Data: \t{data$pathData}",
        "\n\tDocuments: \t{data$pathDataDocs}",
        "\n\tMarkdown: \t{data$pathDataMd}",
        "\n\tRIS: \t{data$pathDataRis}",
        "\nAnalysis: ",
        "\n\tAnalysis: \t{data$pathAnalysis}",
        "\n\tGraphics: \t{data$pathGraphics}",
        "\nScripts: ",
        "\n\tR Scripts: \t{data$pathScriptsR}",
        "\n\tPython Scripts: {data$pathScriptsPy}",
        "\n\tMarkdown Scripts: {data$pathScriptsMd}",
        "\n\tRIS Scripts: \t{data$pathScriptsRis}",
        "\nOther: ",
        "\n\tMetadata: \t{data$pathMetadata}",
        "\n\tNotebooks: \t{data$pathNotebooks}",
    ))
    # Return the data list
    return(data)
}

# check if a file in the global environment
if (!exists("prjDirs")) {
    # if not, load the project directories
    prjDirs <- projectDirectories()
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 3. Bill Structure ####
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Define a function to add the bill structure
addBillStructure <- function(year, bill) {
    # Define variables for the bill
    id <- gsub("-", "", bill)
    period <- paste(year, year + 1, sep = "-")
    type <- switch(strsplit(bill, "-")[[1]][1],
        "AB" = "Assembly Bill",
        "SB" = "Senate Bill",
        "AR" = "Assembly Resolution",
        "SR" = "Senate Resolution",
        "ACR" = "Assembly Concurrent Resolution",
        "SCR" = "Senate Concurrent Resolution",
        "AJR" = "Assembly Joint Resolution",
        "SJR" = "Senate Joint Resolution",
        "ACA" = "Assembly Constitutional Amendment",
        "SCA" = "Senate Constitutional Amendment",
        NA
    )
    urlString <- paste0(year, year+1, "0", id)
    # Create a list entry for the bill
    data <- list(
        bblType = "BILL",
        purpose = "AI",
        id = id,
        type = type,
        no = as.integer(strsplit(bill, "-")[[1]][2]),
        section = period,
        body = "California Legislature",
        session = paste0(period, " Regular Session"),
        text = paste0("https://leginfo.legislature.ca.gov/faces/billTextClient.xhtml?bill_id=", urlString, "&search_keywords=artificial+intelligence"),
        history = paste0("https://leginfo.legislature.ca.gov/faces/billHistoryClient.xhtml?bill_id=", urlString),
        status = paste0("https://leginfo.legislature.ca.gov/faces/billStatusClient.xhtml?bill_id=", urlString),
        votes = paste0("https://leginfo.legislature.ca.gov/faces/billVotesClient.xhtml?bill_id=", urlString),
        analysis = paste0("https://leginfo.legislature.ca.gov/faces/billAnalysisClient.xhtml?bill_id=", urlString),
        todaysLaw = paste0("https://leginfo.legislature.ca.gov/faces/billCompareClient.xhtml?bill_id=", urlString),
        compare = paste0("https://leginfo.legislature.ca.gov/faces/billVersionsCompareClient.xhtml?bill_id=", urlString),
        topic = NA,
        title = paste0(bill, ": "),
        tldr = NA,
        tags = NA,
        sponsors = NA,
        cosponsors = NA,
        dateStart = NA,
        dateEnd = NA,
        dateUpdated = NA,
        version = NA,
        outcome = NA,
        chaptered = NA,
        chapterNo = NA,
        active = NA,
        result = NA,
        vote = NA,
        appropriation = NA,
        fiscal = NA,
        local = NA,
        urgency = NA,
        tax = NA,
        action = NA,
        pdf = NA,
        aiDisposition = NA,
        aiType = NA,
        aiSector = NA,
        aiSubSector = NA,
        aiDomain = NA,
        aiAccountability = NA,
        aiImpact = NA,
        aiEthics = NA,
        aiInnovation = NA,
        aiPrivacy = NA,
        aiTransparency = NA
    )
    # Remove unnecessary variables
    #rm(id, period, type, urlString)
    # Return the data
    return(data)
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 4. Add Sponsors ####
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Create a new function named `sponsors` that generates a list of sponsors
addSponsors <- function(year, names) {
    sponsors_list <- list()
    for (name in names) {
        if (name %in% names(calMembers[[year]])) {
            sponsors_list[[name]] = calMembers[[year]][[name]]
        } else {
            stop(paste("Sponsor", name, "not found in year", year, "Possible alternatives:", grep(substr(name, 1, nchar(name) - 2), names(calMembers[[year]]), value = TRUE)))
        }
    }
    return(sponsors_list)
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 5. Save Functions ####
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Save the metadata function to disk
save(projectMetadata, file = file.path(prjDirs$pathData, "projectMetadata.RData"))

# Save the project directories function to disk
save(projectDirectories, file = file.path(prjDirs$pathData, "projectDirectories.RData"))

# Save the bill structure function to disk
save(addBillStructure, file = file.path(prjDirs$pathData, "addBillStructure.RData"))

# Save the sponsors function to disk
save(addSponsors, file = file.path(prjDirs$pathData, "addSponsors.RData"))

# Clear the workspace
#rm(list = ls())

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# End of Script ####
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
