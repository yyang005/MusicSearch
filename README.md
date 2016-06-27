# AppStoreSearch
This app is to search published software in the App store.

This app has a search bar that accept inputs of key words. once click on the search bar, a keyboard will appear for accepting input. the keyboard will 
hide once the search button is pressed. 
The search results will show in a table view. The author's name and the image associated to each software will be shown in each table view cell.
If there are some error happen during searching, some error message will shown in an alert view controller.
User can tap a row of table view to transit to detail view to see the price info for the specific software and go back to the table view
from the detail view by tapping the area outside the detail view or click x on detail view.
In the table view, user can also swip a row to delete that row.
All the search results are automatically saved using core data. If you terminate the app and restart it the search resutls from last time
are shown in the table view.
User can rotate from potrait mode to landscape mode. In landscape mode, all the images of searched results are shown in a collection view.
User can go from one page to the next page by swiping to the left/right.
