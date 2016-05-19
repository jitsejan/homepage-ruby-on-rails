Article.delete_all

Article.create(
  id: 1,
  title: "Change the last modified time of a file",
  published_at: Time.now,
  body: 
  %Q{This script will change the last modified time of a file in the current directory to 4 days back.
``` shell
#!/bin/ksh 
numDays=4
diff=86400*$numDays
export diff
newDate=$(perl -e 'use POSIX; print strftime "%Y%m%d%H%M", localtime time-$ENV{diff};')
lastFile=$(ls -lt | egrep -v ^d | tail -1 | awk ' { print $9 } ')
touch -t $newDate $lastFile
```
 }
)

Article.create(
  id: 5,
  title: "Create big files with dd",
  published_at: Time.now,
  body: 
  %Q{Use dd in Unix to create files with a size of 2.7 GB.
``` shell
#!/bin/ksh
dir=/this/is/my/outputdir/
numGig=2.7
factor=1024
memLimit=$(expr $numGig*$factor*$factor*$factor | bc)
cd $dir
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 ; do
   dd if=/dev/urandom of=dummy_$i.xml count=204800 bs=$factor
done
```
 }
)
Article.create(
  id: 6,
  title: "Find most used history command",
  published_at: Time.now,
  body: 
  %Q{``` shell
awk '{print $1}' ~/.bash_history | sort | uniq -c | sort -n
```
 }
)

Article.create(
  id: 11,
  title: "Setting up an AWS EC instance",
  published_at: Time.now,
  body: 
  %Q{* Go to the [EC page](https://eu-central-1.console.aws.amazon.com/ec2/v2/home?region=eu-central-1#Instances:sort=instanceId)
* Launch Instance
* Select **Ubuntu Server 14.04 LTS (HVM), SSD Volume Type - ami-87564feb**
* Select **t2.micro (Free tier eligible)**
* Select **Next: Configure Instance Details**
* Select **Next: Add Storage**
* Select **Next: Tag Instance**
* Give a _Name_ to the Instance
* Select **Next: Configure Security Group**
* Create a new security group
* Add a _Security group name_
* Add a _Description_
* Add rule by clicking **Add Rule**
* First rule should be **Custom TCP Rule, TCP Protocol, Port 80 for source Anywhere**
* Click on **Launch**
* Select **Review and launch**
* In the pop-up, select **Create a new key pair**
* Fill in a _Key pair name_
* Download the _Key Pair_ and save in a <u>secure</u> location
* Go to the [instance page](https://eu-central-1.console.aws.amazon.com/ec2/v2/home?region=eu-central-1#Instances:sort=instanceId) and wait until the machine is ready

* On your computer, change the permissions of the key pair you just downloaded
      ~~~ shell
      $ chmod 400 keypairfile.pem
      ~~~
* Connect to the machine via ssh. Click on the Connect button in the instance overview for connection information
      ~~~ shell
      $ ssh -i “keypairfile.pem” ec2-xx-xx-x-xx.eu-central-1.compute.amazonaws.com
      ~~~
}
)

Article.create(
  id: 12,
  title: "Add Flickr pictures to WordPress using PHP",
  published_at: Time.now,
  body: 
  %Q{~~~ php
<?php
define('WP_USE_THEMES', false);
require('../myWordPressSite/wp-load.php');
// Define which photosets should be ignored
$ignore_array = array(
				'Personal', 
				'Backup');
$user 		= '123456@N01';
$api_key 	= '1234abcdefg5678jikl';

/* Retrieve the photos from WordPress and return the Flickr IDs */
function get_wordpress_photos(){
	// Query all custom posts of type 'photo'
	$args = array('post_type' => 'photo', 'posts_per_page' => 500);
	$flickrids = array();
	$loop = new WP_Query( $args );
	// Add all the Flickr IDs from the photos to an array
	if($loop->have_posts()){
		while ( $loop->have_posts() ) : $loop->the_post();
			$flickrids[] = get_post_meta(get_the_ID(), "flickr_id")[0];
		endwhile;
	}
	// Return the IDs of all photos
	return $flickrids;
}
/* Insert the Flickr photo into WordPress */
function insert_wordpress_photo($photo, $photosettitle){
	// Set data for custom post type 'photo'
	$photo_post = array(
	  'post_title'    => $photo['title'],
	  'post_type' 	  => 'photo',
	  'post_status'   => 'publish',
	);
	// Insert the post to WordPress
	$post_id = wp_insert_post( $photo_post );
	// Add the photoset to the inserted photo
	wp_set_object_terms($post_id, $photosettitle, 'photoset', 		true);
	// Add all data from Flickr to the inserted photo
	add_post_meta($post_id, 'flickr_id', 	$photo['id'], 			true);
	add_post_meta($post_id, 'url_m', 	$photo['url_m'], 		true);
	add_post_meta($post_id, 'url_s', 	$photo['url_s'], 		true);
	add_post_meta($post_id, 'url_t', 	$photo['url_t'], 		true);
	add_post_meta($post_id, 'url_sq', 	$photo['url_sq'], 		true);
	add_post_meta($post_id, 'url_o', 	$photo['url_o'], 		true);
	add_post_meta($post_id, 'date_upload', 	$photo['dateupload'], 	true);
	add_post_meta($post_id, 'date_taken', 	$photo['datetaken'], 	true);
}
/* Retrieve the photos from a given photoset from Flickr */
function get_photos_of_photoset($user, $api_key, $photoset_id){
	// Build query for all photos in a given photoset
	$params = array(
		'user_id'		=> $user,
		'api_key'		=> $api_key,
		'photoset_id'     => $photoset_id, 
		'method'		=> 'flickr.photosets.getPhotos',
		'format'		=> 'php_serial',
		'extras' 		=> 'url_m, url_s, url_t, url_sq, url_o, date_upload, date_taken'
	);
	$encoded_params = array();
	foreach ($params as $k => $v){
		$encoded_params[] = urlencode($k).'='.urlencode($v);
	}
	// Build the Flickr URL to query the photos
	$url = "https://api.flickr.com/services/rest/?".implode('&', $encoded_params);
	// Execute the query and save the result
	$rsp = file_get_contents($url);
	$rsp_obj = unserialize($rsp);
	// Return the array with photos for the photoset
	return $rsp_obj['photoset']['photo'];
}
/* Retrieve all photosets for a given user from Flickr */
function get_list_of_photosets($user, $api_key){
	// Build query for all photosets for a given user
	$params = array(
		'user_id'	=> $user,
		'api_key'	=> $api_key,
		'method'	=> 'flickr.photosets.getList',
		'format'	=> 'php_serial',
	);
	$encoded_params = array();
	foreach ($params as $k => $v){
		$encoded_params[] = urlencode($k).'='.urlencode($v);
	}
	// Build the Flickr URL to query the photos
	$url = "https://api.flickr.com/services/rest/?".implode('&', $encoded_params);
	// Execute the query and save the result
	$rsp = file_get_contents($url);
	$rsp_obj = unserialize($rsp);
	// Return the array with photosets
	return $rsp_obj['photosets']['photoset'];
}
/* Main function - Add photos from Flickr to WordPress */
function main($user, $api_key, $ignore_array){
	/* 
	1. Retrieve all images from WordPress
	2. Retrieve all photosets from Flickr
	3. Check if photoset should be ignored
	4. If not, retrieve photos from photosets
	5. Check if photo is already added in WordPress
	6. If not, add photo to WordPress
	*/
	$photosets 	= get_list_of_photosets($user, $api_key);
	$existing_photos = get_wordpress_photos();
	foreach($photosets as $index => $photoset){
		$photosettitle = $photoset['title']['_content'];
		if (!in_array($photosettitle, $ignore_array)) 
		{
			echo '<h2 class="success">Processing '.$photosettitle.'</h2>';
			$photos = get_photos_of_photoset($user, $api_key, $photoset['id']);
			foreach($photos as $index => $photo){
				$imgurl = 'http://farm' . $photo["farm"] . '.static.flickr.com/' . $photo["server"] . '/' . $photo["id"] . '_' . $photo["secret"] . '.jpg'; 
				echo '<p class="info">Found <b>'.$photo['title'].'</b> ['.$imgurl.']</p>';
				if(in_array($photo['id'], $existing_photos)){
					echo '<p class="warning">Ignoring..</p>';
				}else{
					echo '<p class="success">Inserting..</p>';
					insert_wordpress_photo($photo, $photosettitle);
				}
			}
		}else{
			echo '<h2 class="error">Ignoring '.$photosettitle.'</h2>';
		}
	}
}
main($user, $api_key, $ignore_array);
?>
~~~
}
)

Article.create(
  id: 13,
  title: "Add custom post type photo with taxonomy photoset",
  published_at: Time.now,
  body: 
  %Q{~~~ php
<?php
/*Plugin Name: Create Custom Post Types
Description: This plugin registers the photo' post type.
Author: jitsejan
Version: 1.0
License: GPLv2
*/

/**
 * Add custom photo post type
 */
function custom_photo_post_type() {
	// Set UI labels for 'photo' Post Type
	$labels = array(
		'name'                => _x( 'Photos', 'Post Type General Name', 'mytheme' ),
		'singular_name'       => _x( 'Photo', 'Post Type Singular Name', 'mytheme' ),
		'menu_name'           => __( 'Photos', 'mytheme' ),
		'parent_item_colon'   => __( 'Parent photo', 'mytheme' ),
		'all_items'           => __( 'All photos', 'mytheme' ),
		'view_item'           => __( 'View photos', 'mytheme' ),
		'add_new_item'        => __( 'Add new photo', 'mytheme' ),
		'add_new'             => __( 'Add new', 'mytheme' ),
		'edit_item'           => __( 'Edit photo', 'mytheme' ),
		'update_item'         => __( 'Update photo', 'mytheme' ),
		'search_items'        => __( 'Search photo', 'mytheme' ),
		'not_found'           => __( 'Not found', 'mytheme' ),
		'not_found_in_trash'  => __( 'Not found in Trash', 'mytheme' ),
	);
	// Set other options for 'photo' Post Type
	$args = array(
		'label'               => __( 'photo', 'dazzling' ),
		'description'         => __( 'Photo', 'dazzling' ),
		'labels'              => $labels,
		'supports'            => array( 'title' ),
		'hierarchical'        => false,
		'public'              => true,
		'taxonomies'          => array( 'photoset' ),
		'show_ui'             => true,
		'show_in_menu'        => true,
		'show_in_nav_menus'   => true,
		'show_in_admin_bar'   => true,
		'menu_position'       => 7,
		'can_export'          => true,
		'has_archive'         => true,
		'exclude_from_search' => false,
		'publicly_queryable'  => true,
		'capability_type'	=> 'page',
		'menu_icon'		=> 'dashicons-camera',
	);
	// Registering 'photo' Post Type
	register_post_type( 'photo', $args );
	register_taxonomy_for_object_type( 'photoset', 'photo' );
}
/**
 * Add photo custom fields
 */
function add_photo_meta_boxes() {
	add_meta_box("photo_detail_meta", "Photo details", "add_photo_details_photo_meta_box", "photo", "normal", "low");
}
function add_photo_details_photo_meta_box()
{
	global $post;
	$custom = get_post_custom( $post->ID );
 
	?>
	<style>.width99 {width:99%;}</style>
	<p>
		<label>Flickr ID:</label><br />
		<input type="text" name="flickr_id" value="<?= @$custom["flickr_id"][0] ?>" class="width99" />
	</p>
	<p>
		<label>Date taken:</label><br />
		<input type="text" name="date_taken" value="<?= @$custom["date_taken"][0] ?>" class="width99" />
	</p>
	<p>
		<label>Date uploaded:</label><br />
		<input type="text" name="date_upload" value="<?= @$custom["date_upload"][0] ?>" class="width99" />
	</p>
	<p>
		<label>URL [square]:</label><br />
		<input type="text" name="url_sq" value="<?= @$custom["url_sq"][0] ?>" class="width99" />
	</p>
	<p>
		<label>URL [thumb]:</label><br />
		<input type="text" name="url_t" value="<?= @$custom["url_t"][0] ?>" class="width99" />
	</p>
	<p>
		<label>URL [small]:</label><br />
		<input type="text" name="url_s" value="<?= @$custom["url_s"][0] ?>" class="width99" />
	</p>
	<p>
		<label>URL [medium]:</label><br />
		<input type="text" name="url_m" value="<?= @$custom["url_m"][0] ?>" class="width99" />
	</p>
	<p>
		<label>URL [original]:</label><br />
		<input type="text" name="url_o" value="<?= @$custom["url_o"][0] ?>" class="width99" />
	</p>
	<?php
}
/**
 * Save custom field data when creating/updating photo posts
 */
function save_photo_custom_fields(){
  global $post;
 
  if ( $post )
  {
    update_post_meta($post->ID, "flickr_id", @htmlspecialchars($_POST["flickr_id"]));
    update_post_meta($post->ID, "date_taken", @htmlspecialchars($_POST["date_taken"]));
    update_post_meta($post->ID, "date_upload", @htmlspecialchars($_POST["date_upload"]));
    update_post_meta($post->ID, "url_sq", @htmlspecialchars($_POST["url_sq"]));
    update_post_meta($post->ID, "url_t", @htmlspecialchars($_POST["url_t"]));
    update_post_meta($post->ID, "url_s", @htmlspecialchars($_POST["url_s"]));
    update_post_meta($post->ID, "url_m", @htmlspecialchars($_POST["url_m"]));
    update_post_meta($post->ID, "url_o", @htmlspecialchars($_POST["url_o"]));
  }
}
add_action( 'admin_init', 'add_photo_meta_boxes' );
add_action( 'save_post', 'save_photo_custom_fields' );

// Hook into the init action and call create_topics_nonhierarchical_taxonomy when it fires
add_action( 'init', 'create_photosets_nonhierarchical_taxonomy', 0 );

function create_photosets_nonhierarchical_taxonomy() {

// Labels part for the GUI
  $labels = array(
    'name' => _x( 'Photoset', 'taxonomy general name' ),
    'singular_name' => _x( 'photoset', 'taxonomy singular name' ),
    'search_items' =>  __( 'Search photoset' ),
    'popular_items' => __( 'Popular photoset' ),
    'all_items' => __( 'All photoset' ),
    'parent_item' => null,
    'parent_item_colon' => null,
    'edit_item' => __( 'Edit photoset' ), 
    'update_item' => __( 'Update photoset' ),
    'add_new_item' => __( 'Add New photoset' ),
    'new_item_name' => __( 'New photoset Name' ),
    'separate_items_with_commas' => __( 'Separate photosets with commas' ),
    'add_or_remove_items' => __( 'Add or remove photoset' ),
    'choose_from_most_used' => __( 'Choose from the most used photosets' ),
    'menu_name' => __( 'Photoset' ),
  ); 

// Register the non-hierarchical taxonomy like tag
  register_taxonomy('photoset','post',array(
    'hierarchical' => false,
    'labels' => $labels,
    'show_ui' => true,
    'show_admin_column' => true,
    'update_count_callback' => '_update_post_term_count',
    'query_var' => true,
    'rewrite' => array( 'slug' => 'photoset' ),
  ));
}

/**
 * Hook into the 'init' action so that the function
 * containing our post type registration is not 
 * unnecessarily executed. 
 */
add_action( 'init', 'custom_photo_post_type', 0 );

?>
~~~
}
)
  
Article.create(
  id: 14,
  title: "Add Flickr pictures to WordPress using Python",
  published_at: Time.now,
  body: 
  %Q{~~~ python
#!/usr/bin/env python
import flickrapi
from lxml import etree
from wordpress_xmlrpc import Client, WordPressPost, WordPressPage
from wordpress_xmlrpc.methods.posts import GetPosts, NewPost
from wordpress_xmlrpc.methods import posts

# Connection to WordPress
client = Client(''http://myWordPressSitel/xmlrpc.php'', ''username'', ''password'')
# Connection to Flickr
key 		= ''1234abcdefg5678jikl''
secret 		= ''abcdefg12345''
userid		= ''123456@N01''
flickr 		= flickrapi.FlickrAPI(key, secret)
# Ignore the following Flickr albums
ignoreArray = [''Personal'',
			   ''Backup''];

def _get_all_photos(client):
	""" Retrieve all existing photos in WordPress """
	photos = client.call(posts.GetPosts({''post_type'': ''photo'', ''number'': ''250''}))
	imgarray = []
	for photo in photos:
		for field in photo.custom_fields:
			if field[''key''] == ''url'':
				imgarray.append(field[''value''])
	return imgarray

def _insert_wordpress_photo(title, url, photoset):
	""" Insert the Flickr picture into WordPress """
	widget = WordPressPost()		# Create WordPress post
	widget.post_type = ''photo''		# Custom post type ''photo''
	widget.post_status = ''publish''  # Put to publish, not to draft
	widget.title = title			# Insert Flickr title to photo title
	widget.terms_names = {
			''photoset'': [photoset]	# Custom taxonomy is the Flickr photoset
			}
	widget.custom_fields = []
	widget.custom_fields.append({	# Insert the link to the url field
			''key'': ''url'', 
			''value'': url
	})
	widget.id = client.call(posts.NewPost(widget)) # Submot post

def _get_url_from_photo(photo, size):
	""" Get the URL from the photo """
	url = "https://farm" + photo.get(''farm'') + ".staticflickr.com/" 
	url += photo.get(''server'') + "/" + photo.get(''id'') + "_" + photo.get(''secret'')
	url += "_"+size+".jpg"
	return url

def main():
	""" 
	1. Retrieve all images from WordPress
	2. Retrieve all photosets from Flickr
	3. Check if photoset should be ignored
	4. If not, retrieve photos from photosets
	5. Check if photo is already added in WordPress
	6. If not, add photo to WordPress
	"""
	print("Running flickr2wordpress.py")
	sets 	= flickr.photosets.getList(user_id=userid)
	images  = _get_all_photos(client)
	for photoset in sets.findall(".//photoset"):
		setTitle = photoset.find(''title'').text
		print(setTitle)
		if setTitle in ignoreArray:
			print(''Ignoring'')
		else:
			noPhotos = photoset.attrib[''photos'']
			setID = photoset.attrib[''id'']
			for photo in flickr.walk_set(setID):
				url = _get_url_from_photo(photo, ''b'')
				if url not in images:
					print(''- Adding: '' + photo.get(''title'') + '' '' + url +'' ['' + setTitle + '']'')
					_insert_wordpress_photo(photo.get(''title''), url, setTitle)
				else:
					print(''- Ignoring: '' + photo.get(''title'') + '' '' + url + '' ['' + setTitle + '']'')
		
if __name__ == ''__main__'':
    main()
~~~
  }
  )



Article.create(
  id: 16,
  title: "Installing Ruby on Rails",
  published_at: Time.now,
  body: 
  %Q{* Login onto the Linux machine

* First update the system
      ~~~ shell
      $ sudo apt-get update
      ~~~
* Install the dependencies
      ~~~ shell
      $ sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev libgmp-dev libgdbm-dev libncurses5-dev automake libtool bison
      ~~~
}
)
