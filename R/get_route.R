#' Get route from query
#' Take in a original location and destination, return the direction
#' @param origin the original location
#' @param destination the destination
#' @param mode 'driving'(default), 'walking', or 'transit'
#' @param region the city of of original location and destination. 
#' If original and destination is not in the same city, 
#' set `origin_region` and `destination_region` seperately.
#' @param origin_region the city of original location. If not set, use `region` instead.
#' @param destination_region the city of destination. If not set, use `region` instead.
#' @param tactics 10(no expressway), 11(default, shortest time), 12(shortest path).
#' @param coord_type 'bd09ll'(default), 'gcj02'(which Google map and Soso map are using), 'wgs84' for GPS devices.
#' @return a data frame contains longtitude and latitude of the route.
#' @export get_route
#' @importFrom RCurl getForm
#' @importFrom XML htmlTreeParse　xpathSApply xmlValue
#' 
#' @examples
#' \dontrun{
#' bjMap = baidumap('北京', color='bw')
#' df = get_route('首都国际机场', '北京南苑机场', region = '北京')
#' ggmap(bjMap) + geom_path(data = df, aes(lon, lat), alpha = 0.5, col = 'red')
#' }
get_route = function(...){
    rawData = get_routeXML(...)
    return(xml2df(rawData))
}

get_routeXML = function(origin, destination, 
    mode='driving', 
    region = '北京', origin_region = NA, 
    destination_region = NA, 
    tactics = 11, 
    coord_type = 'bd09ll',
    output = 'xml',
    map_ak='')
{
    map_ak %<>% check_mapkey()
    if (is.na(region) && (is.na(origin_region) & is.na(destination_region))) {
        stop('Argument "region" is not setted!')
    }
    get_city = function(x) ifelse(is.na(x), region, x)

    origin_region      = get_city(origin_region)
    destination_region = get_city(destination_region)
    ## get xml data
    url = 'http://api.map.baidu.com/direction/v2'
    param = list(
        mode               = mode, 
        origin             = origin, 
        destination        = destination, 
        origin_region      = origin_region, 
        destination_region = destination_region,
        tactics            = tactics, 
        coord_type         = coord_type, 
        ak                 = map_ak, 
        output             = output
    )
    # browser()
    rawData = POST(url, body = param, encode = "form") %>% content()
    # rawData = getForm(serverAddress, )
    return(rawData)
}

xml2df = function(rawData){
    ## extract longitude and latitude
    tree = htmlTreeParse(rawData, useInternal = TRUE)
    path = xpathSApply(tree, "//path",  xmlValue)
    split_path = function(x){
        xVec = strsplit(x, ';')[[1]]
        xMat = sapply(xVec, function(x) as.numeric(strsplit(x, ',')[[1]]))
        xDf = data.frame(t(xMat), row.names = NULL)
        colnames(xDf) = c('lon', 'lat')
        return(xDf)
    }
    coor_list = lapply(path, split_path)
    ## return a dataframe
    coors = do.call(rbind, coor_list)
    return(coors)
}
