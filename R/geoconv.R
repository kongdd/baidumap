#' Convert geocode
#' Take in geocode from the other source to baidu's geocode
#' @param geocde geocode from the other source
#' @param from takes intergers from 1 to 8. See more in details. 
#' @param to 5 or 6. See more in details.
#' 
#' @references
#' http://developer.baidu.com/map/index.php?title=webapi/guide/changeposition
#' 
#' @export geoconv
geoconv = function(geocode, from=3, to=5, map_ak=''){
    map_ak %<>% check_mapkey()

    if (class(geocode) %in% c('data.frame', 'matrix')){
        geocode = as.matrix(geocode)
        code = apply(geocode, 1, function(x) paste0(x[1], ',', x[2]))
        code_url = paste0(code, ';', collapse = '')
        code_url = substr(code_url, 1, nchar(code_url)-1)
    } else if(length(geocode) == 2){
        code_url = paste0(geocode[1], ',', geocode[2])
    } else{
        stop('Wrong geocodes!')
    }
    
    url_header = 'http://api.map.baidu.com/geoconv/v1/?coords='
    url = paste0(url_header, code_url, '&from=', from, '&to=', to, '&ak=', map_ak, 
                 collapse='')
    result = GET(url) %>% content() %>% fromJSON()
    result_matrix = sapply(result$result, function(t) c(t$x, t$y))
    t(result_matrix)
}
