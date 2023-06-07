import axios from 'axios'
const baseUrl = '/api/users'

let token = null
if(window.localStorage.getItem('token'))
{
  token = `bearer ${JSON.parse(window.localStorage.getItem('token')).token}`
}
const setToken = newToken => {
  token = `bearer ${JSON.parse(window.localStorage.getItem('token')).token}`
}

const getAll = () => {
  const request = axios.get(baseUrl)
  return request.then(response => response.data).catch(error => console.log(error))
}

const getID = () => {
  const loggedUserJSON = window.localStorage.getItem('token')
  if (loggedUserJSON) {
    const user = JSON.parse(loggedUserJSON)
    const request = axios.get(`${baseUrl}/${user.id}`)
    return request.then(response => response.data).catch(error => console.log(error))
  }
  else {
    console.log("User is not logged in, but is trying to Fetch get request")
  }

}
const create = async newObject => {
  const config = {
    headers: { Authorization: token },
  }
  // ! Create uses await while other use then,catch
  const response = await axios.post(baseUrl, newObject, config)
  return response.data
}

const UpdateProfile = (id, newObject) => {
  const config = {
    headers: { Authorization: token },
  }
  const request = axios.put(`${baseUrl}/update/${id}`, newObject, config)
  return request.then(response => response.data).catch(error => console.log(error))
}

const Delete = (id) => {
  const config = {
    headers: { Authorization: token },
  }
  const request = axios.delete(`${baseUrl}/${id}`, config)
  return request.then(response => response.data).catch(error => console.log(error))
}

const connect = (id, newObject) => {
  const config = {
    headers: { Authorization: token },
  }
  const request = axios.put(`${baseUrl}/connect/${id}`, newObject, config)
  return request.then(response => response.data).catch(error => console.log(error))
}
const newobj = { getAll, getID, create, UpdateProfile, setToken, Delete , connect}
export default newobj