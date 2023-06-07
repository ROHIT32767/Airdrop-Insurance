import axios from 'axios'
const baseUrl = '/api/InsuranceOption'

let token = null
if (window.localStorage.getItem('token')) {
    token = `bearer ${JSON.parse(window.localStorage.getItem('token')).token}`
}
const setToken = newToken => {
    token = `bearer ${JSON.parse(window.localStorage.getItem('token')).token}`
}

const getAll = () => {
    const config = {
        headers: { Authorization: token },
    }
    const request = axios.get(baseUrl,config)
    return request.then(response => response.data).catch(error => console.log(error))
}

const getID = (id) => {
    const config = {
        headers: { Authorization: token },
    }
    const loggedUserJSON = window.localStorage.getItem('token')
    if (loggedUserJSON) {
        const request = axios.get(`${baseUrl}/${id}`,config)
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
    const response = await axios.post(baseUrl, newObject, config)
    return response.data
}

const UpdateInsurance = (id, newObject) => {
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

const AcceptRequest = (id, newObject) => {
    const config = {
        headers: { Authorization: token },
    }
    const request = axios.put(`${baseUrl}/accept/${id}`, newObject, config)
    return request.then(response => response.data).catch(error => console.log(error))
}

const RejectRequest = (id, newObject) => {
    const config = {
        headers: { Authorization: token },
    }
    const request = axios.put(`${baseUrl}/reject/${id}`, newObject, config)
    return request.then(response => response.data).catch(error => console.log(error))
}

const ClaimRequest = (id,newObject) => {
    const config = {
        headers: { Authorization: token },
    }
    const request = axios.put(`${baseUrl}/claim/${id}`, newObject, config)
    return request.then(response => response.data).catch(error => console.log(error))
}

const BuyOption = (id,newObject) => {
    const config = {
        headers: { Authorization: token },
    }
    const request = axios.put(`${baseUrl}/buy/${id}`, newObject, config)
    return request.then(response => response.data).catch(error => console.log(error))
}

const newobj = { getAll, getID, create, UpdateInsurance, setToken, Delete, AcceptRequest, RejectRequest , ClaimRequest, BuyOption}
export default newobj