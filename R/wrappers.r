#' Levenshtein Distance
#' 
#' @param s,t
#' Strings.
#' 
#' @export
levenshtein_dist <- function(s, t)
{
  .Call(R_levenshtein_dist, s, t)
}



#' Find Closest Word
#' 
#' @param input
#' A string.
#' @param words
#' A vector of strings (vocabulary) to compare against the input word.
#' 
#' @export
find_closest_word <- function(input, words)
{
  .Call(R_find_closest_word, input, words)
}
