library(yaml)
library(optparse)

# 定义命令行选项
option_list <- list(
    make_option(c("-i", "--input"), dest = "input", type = "character",
                help = "输入文件路径"),
    make_option(c("-o", "--output"), dest = "output", type = "character",default = "csdn",
                help = "输出文件平台，e.g: jianshu, csdn")
)

# 解析命令行参数
opt <- parse_args(OptionParser(option_list = option_list))

#opt=list(input="content/post/2023-04-06-r-map/index.md",output="jianshu")

# 读取Markdown文件
md_file <- opt$input
if(!(file.exists(md_file)&tools::file_ext(md_file)=='md'))stop("file error!")
md_text <- readLines(md_file)

# 提取YAML信息
start_line <- grep("^---$", md_text)
yaml_text <- paste(md_text[(start_line[1]+1):(start_line[2]-1)], collapse = "\n")
file=paste(md_text[(start_line[2]+1):length(md_text)], collapse = "\n")

# 解析YAML信息
yaml_data <- yaml::yaml.load(yaml_text)

# 输出YAML数据
# print(yaml_data)
#根据这个获取部署在netlify上的图片地址
slug=yaml_data$slug

# 替换字符串为外链
md_text1 <- gsub("\\{\\{< blogdown/postref >\\}}", "", file)
md_text1 <- gsub('src="(.*?)"', paste0('src="',"https://asa-blog.netlify.app/p/",slug,"/",'\\1"'), md_text1)
md_text1 <- gsub('\\!\\[(.*?)\\]\\((.*?)\\)',paste0('![\\1](',"https://asa-blog.netlify.app/p/",slug,"/",'\\2)'),md_text1)
md_text1 <- gsub('width=".*?"', 'width="90%"', md_text1)

if(opt$output=="jianshu"){
    print("jianshu")
    #转换html为markdown（适应简书）
    md_text1=gsub('<img src="([^>]*?)" title="(.*?)"[^>]*>', '![\\2](\\1)', md_text1)
    md_text1=gsub('<img src="([^>]*?)"[^>]*>', '![](\\1)', md_text1)
    # 删除HTML标签
    md_text1 <- gsub("<div .*?>", "", md_text1)
    md_text1 <- gsub("</div>", "", md_text1)
    md_text1 <- gsub("<span .*?>", "", md_text1)
    md_text1 <- gsub("</span>", "", md_text1)
}

#添加微信公粽号图片
if(opt$output!="jianshu"){md_text1=paste0(md_text1,"\n\n ![关注公众号，获取最新推送](https://asa-blog.netlify.app/about/images/bio-qrcode.png) \n\n 关注公众号 'biollbug',获取最新推送。")}

clipr::write_clip(md_text1,allow_non_interactive = T)
print(paste0("copy done, paste to ",opt$output))
