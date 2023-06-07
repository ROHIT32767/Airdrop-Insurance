// import React, {useState} from 'react';
// import Button from '@mui/material/Button';
// import Paper from '@mui/material/Paper';
// import InputBase from '@mui/material/InputBase';
// import Divider from '@mui/material/Divider';
// import MenuIcon from '@mui/icons-material/Menu';
// import SearchIcon from '@mui/icons-material/Search';
// import Chip from '@mui/material/Chip';
// import TagIcon from '@mui/icons-material/Tag';
// import Box from '@mui/material/Box';
// import Grid from '@mui/material/Grid';
// import Typography from '@mui/material/Typography';
// import SortIcon from '@mui/icons-material/Sort';
// import Container from '@mui/material/Container';
// import { createTheme, ThemeProvider } from '@mui/material/styles';
// import Card from '@mui/material/Card';
// import CardHeader from '@mui/material/CardHeader';
// import CardMedia from '@mui/material/CardMedia';
// import CardContent from '@mui/material/CardContent';
// import CardActions from '@mui/material/CardActions';
// import IconButton from '@mui/material/IconButton';
// import { red, green } from '@mui/material/colors';
// import Avatar from '@mui/material/Avatar';
// import RedditIcon from '@mui/icons-material/Reddit';
// import OpenInNewIcon from '@mui/icons-material/OpenInNew';
// import InsuranceService from '../services/InsuranceService';
// import { useNavigate } from "react-router-dom";
// import Switch from '@mui/material/Switch';
// import Fuse from 'fuse.js'
// const theme = createTheme();
// export default function MySubGreddits(props) {
//     const navigate = useNavigate()
//     const [subreddits, setSubreddits] = useState([]);
//     const [searchtext, setsearchtext] = useState("");
//     const [displaysubreddits, setdisplaysubreddits] = useState([])
//     const [ascending, setascending] = useState(false)
//     const [descending, setdescending] = useState(false)
//     const [followersort, setfollowersort] = useState(false)
//     const [datesort, setdatesort] = useState(false)
//     const [fuzzysort, setfuzzysort] = useState(false)
//     const [tags, settags] = useState([]);
//     const [selectedTags, setSelectedTags] = useState([]);
//     const [emptydisplaysubreddits, setemptydisplaysubreddits] = useState([])
//     const handleTagClick = (tag) => {
//         if (selectedTags.includes(tag)) {
//             if (selectedTags.length === 1 && searchtext) {
//                 setdisplaysubreddits(subreddits.filter(element => element.Name.toLowerCase().includes((searchtext).toLowerCase())).sort((a, b) => {
//                     if (a.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id) && !b.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id)) {
//                         return -1;
//                     }
//                     if (!a.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id) && b.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id)) {
//                         return 1;
//                     }
//                     return 0;
//                 }))
//                 setSelectedTags([])
//             }
//             else {
//                 setSelectedTags(selectedTags.filter((t) => t !== tag));
//                 setdisplaysubreddits(subreddits.filter(element => element.Name.toLowerCase().includes((searchtext).toLowerCase())).filter(element => element.Tags.some(r => selectedTags.filter(item => item !== tag).indexOf(r) >= 0)).sort((a, b) => {
//                     if (a.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id) && !b.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id)) {
//                         return -1;
//                     }
//                     if (!a.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id) && b.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id)) {
//                         return 1;
//                     }
//                     return 0;
//                 }))
//             }
//         }
//         else {
//             setSelectedTags([...selectedTags, tag]);
//             setdisplaysubreddits(subreddits.filter(element => element.Name.toLowerCase().includes((searchtext).toLowerCase())).filter(element => element.Tags.some(r => selectedTags.concat(tag).indexOf(r) >= 0)).sort((a, b) => {
//                 if (a.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id) && !b.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id)) {
//                     return -1;
//                 }
//                 if (!a.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id) && b.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id)) {
//                     return 1;
//                 }
//                 return 0;
//             }))
//         }

//     };
//     React.useEffect(() => {
//         const fetchData = async () => {
//             try {
//                 const data = await InsuranceService.getAll()
//                 console.log("recieved", data)
//                 setSubreddits(data.map(element => {
//                     return {
//                         ...element,
//                         Name: element.Name,
//                         Description: element.Description,
//                         Expirationdate: element.Expirationdate,
//                         Creationdate: element.Creationdate,
//                         provider: element.provider,
//                         Payout: element.Payout,
//                         Users: element.Users,
//                         Automated: element.Automated
//                     }

//                 }))
//                 setdisplaysubreddits(data.map(element => {
//                     return {
//                         ...element,
//                         Name: element.Name,
//                         Description: element.Description,
//                         Expirationdate: element.Expirationdate,
//                         Creationdate: element.Creationdate,
//                         provider: element.provider,
//                         Payout: element.Payout,
//                         Users: element.Users,
//                         Automated: element.Automated
//                     }
//                 }))
//                 setemptydisplaysubreddits(data.map(element => {
//                     return {
//                         ...element,
//                         Name: element.Name,
//                         Description: element.Description,
//                         Expirationdate: element.Expirationdate,
//                         Creationdate: element.Creationdate,
//                         provider: element.provider,
//                         Payout: element.Payout,
//                         Users: element.Users,
//                         Automated: element.Automated
//                     }
//                 }))
//                 // console.log("Subreddits on Loading are",subreddits)
//             }
//             catch (error) {
//                 console.log(error)
//             }
//         }
//         fetchData();
//     }, [])
//     console.log(subreddits)
//     return (
//         <div>
//             <ThemeProvider theme={theme}>
//                 <Container component="main" maxWidth="xs">
//                     <Box
//                         sx={{
//                             marginTop: 8,
//                             display: 'flex',
//                             flexDirection: 'column',
//                             alignItems: 'center',
//                         }}
//                     ></Box>
//                     <Paper
//                         component="form"
//                         sx={{ marginTop: 8, p: '2px 4px', display: 'flex', alignItems: 'center', width: 400 }}
//                     >
//                         <IconButton sx={{ p: '10px' }} aria-label="menu">
//                             <MenuIcon />
//                         </IconButton>
//                         <InputBase
//                             sx={{ ml: 1, flex: 1 }}
//                             placeholder="Search SubGreddits"
//                             inputProps={{ 'aria-label': 'search subgreddits' }}
//                             value={searchtext}
//                             onChange={event => {
//                                 setsearchtext(event.target.value)
//                                 if (!fuzzysort) {
//                                     if (!event.target.value) {
//                                         setdisplaysubreddits(subreddits.filter(element => element.Tags.some(r => selectedTags.indexOf(r) >= 0)).sort((a, b) => {
//                                             if (a.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id) && !b.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id)) {
//                                                 return -1;
//                                             }
//                                             if (!a.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id) && b.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id)) {
//                                                 return 1;
//                                             }
//                                             return 0;
//                                         }))
//                                     }
//                                     else {
//                                         if (!selectedTags.length) {
//                                             setdisplaysubreddits(subreddits.filter(element => element.Name.toLowerCase().includes((event.target.value).toLowerCase())).sort((a, b) => {
//                                                 if (a.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id) && !b.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id)) {
//                                                     return -1;
//                                                 }
//                                                 if (!a.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id) && b.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id)) {
//                                                     return 1;
//                                                 }
//                                                 return 0;
//                                             }))
//                                         }
//                                         else {
//                                             setdisplaysubreddits(subreddits.filter(element => element.Name.toLowerCase().includes((event.target.value).toLowerCase())).filter(element => element.Tags.some(r => selectedTags.indexOf(r) >= 0)).sort((a, b) => {
//                                                 if (a.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id) && !b.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id)) {
//                                                     return -1;
//                                                 }
//                                                 if (!a.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id) && b.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id)) {
//                                                     return 1;
//                                                 }
//                                                 return 0;
//                                             }))
//                                         }
//                                     }
//                                 }
//                                 else {
//                                     if (!event.target.value) {
//                                         setdisplaysubreddits(subreddits.filter(element => element.Tags.some(r => selectedTags.indexOf(r) >= 0)).sort((a, b) => {
//                                             if (a.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id) && !b.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id)) {
//                                                 return -1;
//                                             }
//                                             if (!a.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id) && b.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id)) {
//                                                 return 1;
//                                             }
//                                             return 0;
//                                         }))
//                                     }
//                                     else {
//                                         if (!selectedTags.length) {
//                                             const options = {
//                                                 findAllMatches: true,
//                                                 keys: ['Name']
//                                             }
//                                             const fuse = new Fuse(subreddits,options)
//                                             const result = fuse.search(event.target.value)
//                                             console.log("result for search text", result, "searchtext", event.target.value)
//                                             setdisplaysubreddits(result.map(element => element['item']))
//                                         }
//                                         else {
//                                             const options = {
//                                                 findAllMatches: true,
//                                                 keys: ['Name']
//                                             }
//                                             const fuse = new Fuse(subreddits.filter(element => element.Tags.some(r => selectedTags.indexOf(r) >= 0)), options)
//                                             const result = fuse.search(event.target.value)
//                                             console.log("result for tags and search text", result, "searchtext", event.target.value)
//                                             setdisplaysubreddits(result.map(element => element['item']))
//                                         }
//                                     }
//                                 }
//                             }}
//                         />
//                         <IconButton type="button" sx={{ p: '10px' }} aria-label="search">
//                             <SearchIcon />
//                         </IconButton>
//                     </Paper>
//                 </Container>
//                 <Container component="main" maxWidth="xs">
//                     <Box
//                         sx={{
//                             marginTop: 2,
//                             display: 'flex',
//                             flexDirection: 'row',
//                             alignItems: 'center',
//                         }}
//                     >
//                         <Grid item xs={18} sm={3}>
//                             <SortIcon />
//                         </Grid>
//                         <Divider sx={{ height: 28, m: 0.5 }} orientation="vertical" />
//                         <Grid item xs={18} sm={3}>
//                             {
//                                 (descending || followersort || datesort) ? (
//                                     <Button disabled variant="contained" color="secondary" >Ascending</Button>)
//                                     :
//                                     (
//                                         <Button variant="contained" color="secondary" onClick={event => {
//                                             setascending(true)
//                                             setdatesort(false)
//                                             setdescending(false)
//                                             setfollowersort(false)
//                                             !searchtext && !selectedTags.length ? setemptydisplaysubreddits([...subreddits].sort((a, b) => {
//                                                 return a.Name.localeCompare(b.Name)
//                                             })) :
//                                                 setdisplaysubreddits(displaysubreddits.sort((a, b) => {
//                                                     return a.Name.localeCompare(b.Name)
//                                                 }))

//                                         }}>Ascending</Button>
//                                     )
//                             }
//                         </Grid>
//                         <Divider sx={{ height: 28, m: 0.5 }} orientation="vertical" />
//                         <Grid item xs={18} sm={3}>
//                             {
//                                 (ascending || followersort || datesort) ? (
//                                     <Button disabled variant="contained" color="secondary" >Descending</Button>)
//                                     :
//                                     (
//                                         <Button variant="contained" color="secondary" onClick={event => {
//                                             console.log("Descending")
//                                             setascending(false)
//                                             setdatesort(false)
//                                             setdescending(true)
//                                             setfollowersort(false)
//                                             !searchtext && !selectedTags.length ? setemptydisplaysubreddits([...subreddits].sort((a, b) => {
//                                                 return b.Name.localeCompare(a.Name)
//                                             })) :
//                                                 setdisplaysubreddits(displaysubreddits.sort((a, b) => {
//                                                     return b.Name.localeCompare(a.Name)
//                                                 }))
//                                         }}>Descending</Button>
//                                     )
//                             }
//                         </Grid>
//                         <Divider sx={{ height: 28, m: 0.5 }} orientation="vertical" />
//                         <Grid item xs={15} sm={3}>
//                             {
//                                 (ascending || descending || datesort) ? (
//                                     <Button disabled variant="contained" color="secondary" >Followers</Button>)
//                                     :
//                                     (<Button variant="contained" color="secondary" onClick={event => {
//                                         setascending(false)
//                                         setdatesort(false)
//                                         setdescending(false)
//                                         setfollowersort(true)
//                                         !searchtext && !selectedTags.length ? setemptydisplaysubreddits([...subreddits].sort((a, b) => {
//                                             return b.Followers.length - a.Followers.length;
//                                         })) :
//                                             setdisplaysubreddits(displaysubreddits.sort((a, b) => {
//                                                 return b.Followers.length - a.Followers.length;
//                                             }))
//                                     }}>Followers</Button>)
//                             }
//                         </Grid>
//                         <Divider sx={{ height: 28, m: 0.5 }} orientation="vertical" />
//                         <Grid item xs={18} sm={3}>
//                             {
//                                 (ascending || descending || followersort) ? (
//                                     <Button disabled variant="contained" color="secondary" >Date</Button>)
//                                     :
//                                     (
//                                         <Button variant="contained" color="secondary" onClick={event => {
//                                             setascending(false)
//                                             setdatesort(true)
//                                             setdescending(false)
//                                             setfollowersort(false)
//                                             !searchtext && !selectedTags.length ? setemptydisplaysubreddits([...subreddits].sort((a, b) => {
//                                                 return new Date(b.date) - new Date(a.date);
//                                             })) :
//                                                 setdisplaysubreddits(displaysubreddits.sort((a, b) => {
//                                                     return new Date(b.date) - new Date(a.date);
//                                                 }))
//                                         }}>Date</Button>
//                                     )
//                             }
//                         </Grid>
//                         <Divider sx={{ height: 28, m: 0.5 }} orientation="vertical" />
//                         <Grid item xs={15} sm={3}>
//                             {
//                                 <Switch
//                                     checked={fuzzysort}
//                                     onChange={() => setfuzzysort(!fuzzysort)}
//                                     name="Fuzzy"
//                                     color="primary"
//                                 />
//                             }
//                         </Grid>
//                         <Divider sx={{ height: 28, m: 0.5 }} orientation="vertical" />
//                         <Grid item xs={18} sm={3}>
//                             <Button variant="contained" color="secondary" onClick={event => {
//                                 setascending(false)
//                                 setdatesort(false)
//                                 setdescending(false)
//                                 setfollowersort(false)
//                                 setfuzzysort(false)
//                                 if (!searchtext && !selectedTags.length) {
//                                     setemptydisplaysubreddits([...subreddits])
//                                 }
//                                 else if (!searchtext) {
//                                     setdisplaysubreddits(subreddits.filter(element => element.Tags.some(r => selectedTags.indexOf(r) >= 0)).sort((a, b) => {
//                                         if (a.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id) && !b.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id)) {
//                                             return -1;
//                                         }
//                                         if (!a.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id) && b.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id)) {
//                                             return 1;
//                                         }
//                                         return 0;
//                                     }))
//                                 }
//                                 else if (!selectedTags.length) {
//                                     setdisplaysubreddits(subreddits.filter(element => element.Name.toLowerCase().includes((searchtext).toLowerCase())).sort((a, b) => {
//                                         if (a.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id) && !b.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id)) {
//                                             return -1;
//                                         }
//                                         if (!a.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id) && b.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id)) {
//                                             return 1;
//                                         }
//                                         return 0;
//                                     }))
//                                 }
//                                 else {
//                                     setdisplaysubreddits(subreddits.filter(element => element.Name.toLowerCase().includes((searchtext).toLowerCase())).filter(element => element.Tags.some(r => selectedTags.indexOf(r) >= 0)).sort((a, b) => {
//                                         if (a.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id) && !b.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id)) {
//                                             return -1;
//                                         }
//                                         if (!a.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id) && b.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id)) {
//                                             return 1;
//                                         }
//                                         return 0;
//                                     }))
//                                 }
//                             }}>None</Button>
//                         </Grid>
//                     </Box>
//                 </Container>
//                 <Container component="main" maxWidth="xs">
//                     <Box
//                         sx={{
//                             marginTop: 2,
//                             display: 'flex',
//                             flexDirection: 'row',
//                             alignItems: 'center',
//                         }}
//                     >
//                         <Grid item xs={15} sm={3}>
//                             <TagIcon />
//                         </Grid>
//                         <Divider sx={{ height: 28, m: 0.5 }} orientation="vertical" />
//                         <Paper sx={{
//                             display: 'flex',
//                             justifyContent: 'center',
//                             flexWrap: 'wrap',
//                             listStyle: 'none',
//                             padding: theme.spacing(0.5),
//                             margin: 0
//                         }}>
//                             {tags.map((tag) => (
//                                 <div>
//                                     <Chip
//                                         key={tag}
//                                         label={tag}
//                                         onClick={() => handleTagClick(tag)}
//                                         sx={{ margin: theme.spacing(0.5) }}
//                                         color={selectedTags.includes(tag) ? 'primary' : 'default'}
//                                     />
//                                 </div>
//                             ))}
//                         </Paper>
//                     </Box>
//                 </Container>
//                 <Container component="main" sx={{ mt: 5 }}>
//                     <Grid container spacing={4}>
//                         {
//                             (!searchtext && !selectedTags.length) ?
//                                 emptydisplaysubreddits.map(subreddit => {
//                                     return <Grid sx={{ mt: 5 }} xs={12} sm={6}>
//                                         <Card sx={{ maxWidth: 500, bgcolor: green[500] }}>
//                                             <CardHeader
//                                                 avatar={
//                                                     <Avatar sx={{ bgcolor: red[500] }} aria-label="recipe">
//                                                         <RedditIcon style={{ fontSize: "2rem" }} />
//                                                     </Avatar>
//                                                 }
//                                                 title={subreddit.Name}
//                                                 subheader={`Banned Keywords ${subreddit.Banned.join(',')}`}
//                                             />
//                                             <CardMedia
//                                             // TODO: Attach image Here
//                                             />
//                                             <CardContent>
//                                                 <Typography variant="body2" color="text.secondary">
//                                                     {subreddit.Posts.length} Posts
//                                                 </Typography>
//                                                 <Typography variant="body2" color="text.secondary">
//                                                     {subreddit.Followers.length} Followers
//                                                 </Typography>
//                                                 <Typography variant="body2" color="text.secondary">
//                                                     Description : {subreddit.Description}
//                                                 </Typography>
//                                             </CardContent>
//                                             <CardActions disableSpacing>
//                                                 {
//                                                     subreddit.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id) ?
//                                                         <IconButton aria-label="add to favorites">
//                                                             <OpenInNewIcon onClick={event => {
//                                                                 const UpdateClick = async () => {
//                                                                     try {
//                                                                         const data = await InsuranceService.UpdateClicks(subreddit._id)
//                                                                         console.log("Updated Clicks", data)
//                                                                     }
//                                                                     catch (error) {
//                                                                         console.log(error)
//                                                                     }
//                                                                 }
//                                                                 UpdateClick();
//                                                                 navigate(`/ViewSubGreddits/${subreddit._id}`)
//                                                             }} />
//                                                         </IconButton>
//                                                         :
//                                                         <IconButton disabled aria-label="add to favorites">
//                                                             <OpenInNewIcon />
//                                                         </IconButton>
//                                                 }
//                                             </CardActions>
//                                         </Card>
//                                     </Grid>
//                                 })
//                                 :
//                                 displaysubreddits.map(subreddit => {
//                                     return <Grid sx={{ mt: 5 }} xs={12} sm={6}>
//                                         <Card sx={{ maxWidth: 500, bgcolor: green[500] }}>
//                                             <CardHeader
//                                                 avatar={
//                                                     <Avatar sx={{ bgcolor: red[500] }} aria-label="recipe">
//                                                         <RedditIcon style={{ fontSize: "2rem" }} />
//                                                     </Avatar>
//                                                 }
//                                                 title={subreddit.Name}
//                                             />
//                                             <CardMedia
//                                             // TODO: Attach image Here
//                                             />
//                                             <CardContent>
//                                                 <Typography variant="body2" color="text.secondary">
//                                                     {subreddit.Posts.length} Posts
//                                                 </Typography>
//                                                 <Typography variant="body2" color="text.secondary">
//                                                     {subreddit.Followers.length} Followers
//                                                 </Typography>
//                                                 <Typography variant="body2" color="text.secondary">
//                                                     Description : {subreddit.Description}
//                                                 </Typography>
//                                             </CardContent>
//                                             <CardActions disableSpacing>
//                                                 {
//                                                     subreddit.Followers.map(element => element._id).includes(JSON.parse(window.localStorage.getItem('token')).id) ?
//                                                         <IconButton aria-label="add to favorites">
//                                                             <OpenInNewIcon onClick={event => navigate(`/ViewSubGreddits/${subreddit._id}`)} />
//                                                         </IconButton>
//                                                         :
//                                                         <IconButton disabled aria-label="add to favorites">
//                                                             <OpenInNewIcon />
//                                                         </IconButton>
//                                                 }
//                                             </CardActions>
//                                         </Card>
//                                     </Grid>
//                                 })
//                         }
//                     </Grid>
//                 </Container>
//             </ThemeProvider>
//         </div >
//     )
// }