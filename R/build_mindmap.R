# build_mindmap.R — regenerate content/page/MindMap/index.md
# Deterministic rebuild: explicit ordered section hierarchy + post->section map.
suppressPackageStartupMessages({library(dplyr); library(yaml)})

MD  <- "content/page/MindMap/index.md"   # destination
SRC <- MD                                 # seed source: the current (already-curated) file

## ---- 1. ground truth posts (real permalink slug = YAML slug) ----
all_md <- list.files("content/post/", pattern = "^index.*\\.md$", recursive = TRUE, full.names = TRUE)
folders <- dirname(all_md)
all_md <- all_md[!duplicated(folders)]
parse_yaml <- function(f) {
  txt <- readLines(f, warn = FALSE); st <- grep("^---$", txt)
  if (length(st) < 2) return(NULL)
  tryCatch(yaml.load(paste(txt[(st[1]+1):(st[2]-1)], collapse = "\n")), error = function(e) NULL)
}
posts <- do.call(rbind, lapply(all_md, function(f) {
  y <- parse_yaml(f); fo <- basename(dirname(f))
  data.frame(folder = fo,
             slug = if (!is.null(y$slug)) paste0(y$slug, collapse = "") else fo,
             title = if (!is.null(y$title)) y$title else fo,
             stringsAsFactors = FALSE)
}))
# Each post's YAML slug is the authoritative permalink; folders are just storage.
posts <- posts[!duplicated(posts$slug), ]

## ---- 2. seed: existing placements (slug -> section path) ----
raw <- readLines(SRC)
lev <- character(0)
seed <- character(0)
for (ln in raw) {
  h <- regmatches(ln, regexec("^(#{2,6}) (.*)", ln))[[1]]
  if (length(h) == 3) {
    n <- nchar(h[2])
    if (length(lev) >= n) lev <- lev[seq_len(n - 1)]
    lev[n] <- h[3]
    # section path = the section's own name only at each level (skip NA quirk)
    cur <- paste(na.omit(lev[seq_len(n)]), collapse = "/")
    next
  }
  m <- regmatches(ln, regexec("^\\- \\[(.+)\\]\\([../]*p/([^)]+)\\)", ln))[[1]]
  if (length(m) == 3) seed[m[3]] <- cur
}
# canonicalise seed slugs -> real post slug (case-insensitive)
post_lc <- setNames(posts$slug, tolower(posts$slug))
seed_canon <- character(0)
for (s in names(seed)) {
  real <- unname(post_lc[tolower(s)])
  if (!is.null(real) && !is.na(real) && nzchar(real)) {
    v <- seed[[s]]
    # normalise to short path: drop the leading top-level category token
    if (grepl("/", v)) v <- sub("^[^/]+/", "", v)
    seed_canon[real] <- v
  }
}

## ---- 3. place/retarget posts with explicit sections ----
# value = section path like "宏基因组分析/BGCs" (top-level inferred by first token)
missing_sec <- c(
  "2023-03-10-markdown"        = "其他工具",
  "2023-03-14-start-of-spring" = "随笔",
  "werving-of-jiang-lab"       = "随笔",
  "soil-microbiome"            = "微生物生态学",
  "growth"                     = "宏基因组分析",
  "metanet-bioRxiv"            = "网络分析",
  "metatraits"                 = "宏基因组分析",
  "big-scape-slice-2"          = "宏基因组分析/BGCs",
  "snowmelt"                   = "微生物生态学/冻土相关专题",
  "hgt-nc"                     = "微生物生态学",
  "spire-gcmeta"               = "数据库",
  "necromass"                  = "微生物生态学",
  "cnps"                       = "数据库",
  "climate-arg"                = "微生物生态学",
  "baqlava"                    = "宏基因组分析/Virus",
  "moiraine-r"                 = "R语言精进",
  "global-transit"             = "宏基因组分析/Virus",
  "gsva"                       = "富集分析",
  "arctic-streams-n"           = "微生物生态学/冻土相关专题",
  "polaromonas"                = "微生物生态学",
  "global-wastewater"          = "宏基因组分析",
  "grodon-phydon"              = "宏基因组分析",
  "groundwater-virus"          = "宏基因组分析/Virus",
  "asgard-review"              = "微生物生态学",
  "decode-nature-methods"      = "宏基因组分析",
  "evo-2-nature"               = "其他工具",
  "gut-spatial-transcriptomics" = "宏基因组分析",
  "Azithromycin-lung"          = "宏基因组分析",
  "Epistasis-co-adaptation"    = "微生物生态学",
  "global-nitrogen-phosphorus" = "微生物生态学",
  "microbial-phosphorus-cycling" = "微生物生态学",
  "plasmid-arg"                = "宏基因组分析",
  "virome-gene-env"            = "宏基因组分析/Virus",
  "genetics-oral"              = "宏基因组分析",
  "nbt-myloasm-k-mer"          = "宏基因组分析",
  "adipose-tissue-microbiome"  = "宏基因组分析",
  "aquatic-plastisphere"       = "微生物生态学",
  "nbt-erast"                  = "其他工具",
  "nc-defensome"               = "宏基因组分析",
  "args-challenges"            = "宏基因组分析",
  "eemc"                       = "宏基因组分析",
  "nbt-famsa2"                 = "其他工具",
  "nc-archetypes-airway"       = "宏基因组分析",
  "phage-arbitrium"            = "微生物生态学",
  "unbinned-contigs"           = "宏基因组分析",
  "metanet-bioinformatics"     = "网络分析",
  "r-joint-model"              = "统计学",
  "r-latent-class"             = "统计学",
  "r-mofa"                     = "统计学",
  "batch-effect"               = "统计学",
  "mmseqs2"                    = "宏基因组分析",
  "crispr-analysis"            = "宏基因组分析/Virus",
  "c-cycling"                  = "微生物生态学",
  "n-cycling"                  = "微生物生态学",
  "r-machine-learning"         = "R语言精进",
  "r-package"                  = "R语言精进",
  "trophic-strategy"           = "微生物生态学",
  "differential-abundance-analysis" = "统计学",
  "r-rvest"                    = "R语言精进",
  "julia"                      = "编程基础",
  "quarto"                     = "编程基础",
  "circos"                     = "R语言精进",
  "r-medicine"                 = "R语言精进",
  "r-treemap"                  = "R语言精进",
  # deduplicate cross-listed posts to one primary section
  "r-statistics"               = "统计学",
  "sem"                        = "统计学",
  "slurm"                      = "编程基础",
  "antibiotics-resistance"     = "微生物生态学",
  "antismash"                  = "宏基因组分析/BGCs",
  "bgcs"                       = "宏基因组分析/BGCs",
  "big-scape-bgcs"             = "宏基因组分析/BGCs",
  "bgc-atlas"                  = "宏基因组分析/BGCs",
  "gcf-big-fam"                = "宏基因组分析/BGCs",
  "gtdb"                       = "宏基因组分析/MAGs",
  "vire"                       = "宏基因组分析/Virus",
  "global-air-virus"           = "宏基因组分析/Virus",
  "grsa-bib"                   = "富集分析",
  "iPhylo"                     = "其他工具"
)

assign <- c(missing_sec, seed_canon)
assign <- assign[!duplicated(names(assign))]

unassigned <- setdiff(posts$slug, names(assign))
if (length(unassigned)) {
  cat("Unassigned:", length(unassigned), "\n"); print(posts[posts$slug %in% unassigned, c("slug","title")])
}

## ---- 4. explicit ordered hierarchy (top-level then children) ----
# top-level categories in original document order
tops <- c("生信学习", "其他工具", "学术成果", "随笔")
# ordered children per top-level
children <- list(
  "生信学习" = c("编程基础", "R语言精进", "统计学", "宏基因组分析", "数据库",
                 "微生物生态学", "网络分析", "富集分析"),
  "其他工具" = character(0),
  "学术成果" = character(0),
  "随笔"     = character(0)
)
# deeper children of leaf children (only 宏基因组分析 and 微生物生态学 have sub-sections)
grandchildren <- list(
  "宏基因组分析" = c("MAGs", "BGCs", "Virus"),
  "微生物生态学" = c("冻土相关专题")
)

# helper: emit posts directly under a section path, sorted by title
emit_posts <- function(path) {
  sl <- names(assign)[assign == path]
  if (!length(sl)) return(character(0))
  titles <- posts$title[match(sl, posts$slug)]
  vapply(order(titles, sl), function(j) sprintf("- [%s](../p/%s)", titles[j], sl[j]), character(1))
}

out <- c("---", 'date: "2019-05-28"', "layout: mindmap",
         "menu:", "  main:", "    params:", "      icon: mindmap",
         "    weight: -70",
         "slug: mindmap", "title: Mindmap", "---", "")

# 生信学习 is a pure container (##); children at ###, grandchildren at ####.
body <- character(0)
for (t in tops) {
  body <- c(body, paste0("## ", t))
  kids <- children[[t]]
  if (length(kids) == 0) {
    body <- c(body, emit_posts(t))            # standalone top category
  } else {
    for (k in kids) {
      body <- c(body, paste0("### ", k))
      gkids <- grandchildren[[k]]
      if (length(gkids)) {
        body <- c(body, emit_posts(k))
        for (g in gkids) {
          body <- c(body, paste0("#### ", g))
          body <- c(body, emit_posts(paste0(k, "/", g)))
        }
      } else {
        body <- c(body, emit_posts(k))
      }
    }
  }
}

out <- c(out, body)
out <- out[!is.na(out)]
writeLines(out, MD)
cat("\nWrote", length(out), "lines to", MD, "\n")
cat("Link lines:", sum(grepl("^- \\[", out)), " | posts:", nrow(posts), "\n")
cat("Per section:\n"); print(sort(table(assign), decreasing = TRUE))
