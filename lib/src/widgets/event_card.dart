import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
import 'package:korazon/src/cloudresources/firestore_methods.dart';
import 'package:korazon/src/data/providers/user_provider.dart';
import 'package:korazon/src/utilities/design_variables.dart';
//import 'package:korazon/src/widgets/like_animation.dart';
import 'package:provider/provider.dart';


class EventCard extends StatefulWidget {
  final Map<String, dynamic> snap;

  const EventCard({super.key, required this.snap});
  // this is the standard way of defining the key in a widget

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool isLikeAnimating = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.getUser;

    // we imported the user data
    return Container(
      color: secondaryColor,
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 16,
            ).copyWith(
                right:
                    0), //copy with creates a copy of the immutable object, in this case
            //EdgeInsets and overwrites the right padding with the value 0, over the previously set 4
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: widget.snap['accountImage'] != null
                      ? NetworkImage(widget.snap['accountImage'])
                      : const AssetImage('assets/images/test.jpg')
                          as ImageProvider,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'accountname',
                          //?widget.snap['accountname'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(

                          // TODO: Fix the lisview

                          child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              // Add your onTap functionality here
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              child: const Text('Delete'),
                            ),
                          );
                        },
                      ) /*ListView( //USE: ListView.Builder so all posts are not generated at the same time
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shrinkWrap: true,
                      children: [
                        'Delete',
                      ]
                        .map(
                          (e) => InkWell(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16),
                              child: Text(e),
                            ),
                          ),
                        ), //this way the list view is only as tall as its contents
                    ),*/
                          ),
                    );
                  },
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),

          //IMAGE SECTION
//TODO: remove this
/*
          GestureDetector(
            onDoubleTap: () async{
            TODO:  await FirestoreMethods().likePost( // 1.postId 2.uid 3.Likes[]
              //! 
                widget.snap['postId'],
                widget.snap['uid'],
                widget.snap['likes'],
              );
              setState(() {
                isLikeAnimating = true;
              }); //TODO: Double Tap should only add like not remove them
            },
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                width: double.infinity,
                child:
                    Image.asset('assets/images/concert_images.jpeg'),
                    //! This is what it should be: Image.network(widget.snap['photoUrl'], fit: BoxFit.cover),
              ),
              AnimatedOpacity(
                opacity: isLikeAnimating? .9 : 0, //? Value super subject to change as well as color
                  // If it is animating it will show if not it will be hidden.
                duration: const Duration(milliseconds: 200),
                child: LikeAnimation(
                displayObject: const Icon(
                  Icons.favorite,
                  color: primaryColor,
                  size: 120,
                ),
                isAnimating: isLikeAnimating,
                duration: const Duration(
                  milliseconds: 400,
                ),
                onEnd: () {
                  
                  setState(() {
                    isLikeAnimating = false;
                  });
                },
                ),
              ),
            ]),
          ),

 */         //LIKES & COMMENTS SECTION

          Row(
            children: [
              /*LikeAnimation(
                isAnimating: widget.snap['likes'].contains(user?.uid),
                smallLike: true,
                displayObject: IconButton(
                  onPressed: () async{
                    await FirestoreMethods().likePost( // 1.postId 2.uid 3.Likes[]
                    widget.snap['postId'],
                    widget.snap['uid'],
                    widget.snap['likes'],
                    );
                  },
                  icon: widget.snap['likes'].contains(widget.snap['uid']) ? const Icon(
                    Icons.favorite,
                    color: primaryColor,
                  ): const Icon(
                    Icons.favorite_border,
                    color: primaryColor,
                  )
                ),
              ),*/
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.comment_outlined,
                  color: Colors.grey,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.send,
                  color: Colors.grey,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.bookmark),
                  ),
                ),
              ),
            ],
          ),

          // *DESCRIPTION & COMMENTS

          Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontWeight: FontWeight.w800),
                  child: (Text('likes'
                    '//! this is what it should be ${widget.snap['likes'].length} likes', //wee need to use this notation because likes is an array (list<dynamic>)
                    // The ${} allows to display expressions inside string literals

                    style: Theme.of(context).textTheme.bodyMedium,
                  )),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: RichText(
                    text: TextSpan(
                        style: TextStyle(
                          color: primaryColor,
                        ),
                        children: [
                          TextSpan(
                            text: widget.snap['username'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: widget.snap['description'],
                          )
                        ]),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'view 200 comments',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    //DateFormat.yMMMd().format(
                      widget.snap['datePublished'].toDate(),
                   // ),
                    //makes use of intl //*in the future it should change the format of the date according to the time passed

                    style: const TextStyle(
                      fontSize: 16,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
