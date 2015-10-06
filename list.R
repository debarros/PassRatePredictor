#list.R
#This function allows lists to be returned by functions
#It was downloaded from http://gsubfn.googlecode.com/svn/trunk/R/list.R
#It is available under the GNU Public License
#It is part of the gsubfn package, written by G. Grothendieck <ggrothendieck@gmail.com>
#Description of the package can be found at http://gsubfn.googlecode.com/svn/trunk/DESCRIPTION

list <- structure(NA,class="result")
"[<-.result" <- function(x,...,value) {
  args <- as.list(match.call())
  args <- args[-c(1:2,length(args))]
  length(value) <- length(args)
  for(i in seq(along=args)) {
    a <- args[[i]]
    if(!missing(a)) eval.parent(substitute(a <- v,list(a=a,v=value[[i]])))
  }
  x
}