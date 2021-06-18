import 'package:flutter/material.dart';
import 'model/data/dummys_repository.dart';
import 'model/response/movies_response.dart';

class GridPage extends StatelessWidget {
  final List<Movie> movies = DummysRepository.loadDummyMovies();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: (9/16),
        ),
        itemBuilder: (context, index) {
          return _buildDummyItem(movies[index]);
        },
        itemCount: movies.length,
        scrollDirection: Axis.vertical,
    );
  }

  Widget _buildDummyItem(Movie movie){
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Image.network(
                  movie.thumb,
                  fit: BoxFit.fill,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Container(
                  padding: EdgeInsets.all(8.0),
                  child: _buildGradeImage(movie.grade),
                )
              ],
              alignment: Alignment.topRight,
            ),
          ),
          SizedBox(height: 8.0,),
          FittedBox(
            child: Text(
              movie.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )
            ),
          ),
          SizedBox(height: 8.0,),
          Text(
            '${movie.reservationGrade}위(${movie.userRating}) / ${movie.reservationRate}'
          ),
          SizedBox(height: 8.0,),
          Text('${movie.date}'),
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