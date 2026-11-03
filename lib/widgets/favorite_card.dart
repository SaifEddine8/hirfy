import 'package:flutter/material.dart';
import 'package:hirfy/models/work_model.dart';
import 'package:hirfy/screens/work_details_screen.dart';

class FavoriteCard extends StatelessWidget {
  final WorkModel work;
  final VoidCallback onRemove; 
  const FavoriteCard({
    super.key,
    required this.work,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap:()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>WorkDetailsScreen(work: work,))),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[100],
                    child: work.imageUrl.isNotEmpty
                        ? Image.network(
                            work.imageUrl,
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.handyman_outlined,
                            color: Colors.grey,
                            size: 30,
                          ),
                  ),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        work.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        work.craftsmanName,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${work.price} JOD',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}