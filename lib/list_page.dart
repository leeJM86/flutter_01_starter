import 'package:flutter/material.dart';
import 'package:padak_starter/detail_page.dart';
import 'model/data/dummys_repository.dart';
import 'model/response/movies_response.dart';

class ListPage extends StatelessWidget {
  final List<Movie> movies = DummysRepository.loadDummyMovies();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemBuilder: (context, index) {
          //return _buildDummyItem(movies[index]);
          return InkWell(
            child: _buildDummyItem(movies[index]),
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                    transitionDuration: Duration(milliseconds: 200),
                    reverseTransitionDuration: Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return DetailPage(movies[index].id);
                    },
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      var begin = Offset(1.0, 0.0);
                      var end = Offset.zero;
                      var curve = Curves.fastLinearToSlowEaseIn;

                      var tween = Tween(begin: begin, end: end);
                      var curvedAnimation = CurvedAnimation(
                        parent: animation,
                        curve: curve,
                      );

                      return SlideTransition(
                        position: tween.animate(curvedAnimation),
                        child: child,
                      );
                    },
                ),
                /*MaterialPageRoute(
                    builder: (context) {
                      return DetailPage(movies[index].id);
                    },
                ),*/
              );
            },
          );
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemCount: movies.length,
    );
  }

  Widget _buildDummyItem(Movie movie){
    return Container(
      padding: EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image.network(
              movie.thumb,
              height: 120
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      movie.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    _buildGradeImage(movie.grade),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Text('평점 : ${movie.userRating}'),
                    SizedBox(width: 10),
                    Text('예매순위 : ${movie.reservationGrade}'),
                    SizedBox(width: 10),
                    Text('예매율 : ${movie.reservationRate}')
                  ],
                ),
                SizedBox(height: 10),
                Text('개봉일 : ${movie.date}')
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGradeImage(int grade) {
    switch (grade) {
      case 0:
        return Image.asset("assets/ic_allages.png");
      case 12:
        return Image.asset("assets/ic_12.png");
      case 15:
        return Image.asset("assets/ic_15.png");
      case 19:
        return Image.asset("assets/ic_19.png");
      default:
        return null;
    }
  }
}