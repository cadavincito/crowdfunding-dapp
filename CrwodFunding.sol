// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract CrowdFunding {

    //This state determines if the proyect is open to recieve more
    //funds or not
    //ENUMS Are indexed at 0
    enum FundingState {Opened,Closed}

    // project struct
    struct Project {
        string id;
        string name;
        string description;
        //this variable references 
        //the founder´s address
        address payable author;
        FundingState state;
        uint funds;
        uint fundraising;
    }

    struct Contribution{
        address contributor;
        uint value;
    }


    //Projects array
    //Here are stored all the 
    //projects, as they are created
    Project[] public projects;
    
    // map for contributions
    mapping(string => Contribution[]) public contributions;
    

    // EVENTS

    //This event is emmited when a project is created.
    event ProjectCreated(string id,string name,string _description,uint _fundraisingGoal);
    
    //This event is emmited when a project is funded.
    event ProjectFunded(string id, uint value);

    //This event is emmited when a project state is changed.
    event ProjectStateChanged(string id, FundingState newState);
   
  
    modifier isAuthor(uint index){
        require(msg.sender == projects[index].author, "only the author can call this function");
        _;
    }

     modifier isNotAuthor(uint index){
        require(msg.sender != projects[index].author, "the author cannot fund its own projecto");
        _;
    }

    function createProject (string calldata _id,string calldata _name, string calldata _description, uint _fundraisingGoal) public {
            require(_fundraisingGoal>0, "the fundraising goal must be greater than 0");
            Project memory p = Project(_id,_name,_description,payable(msg.sender),FundingState.Opened,0,_fundraisingGoal);
            projects.push(p);
            emit ProjectCreated(_id,_name,_description,_fundraisingGoal);
    }


  
    function fundProject(uint projectIndex) public payable isNotAuthor(projectIndex) {
        Project memory project = projects[projectIndex];
        require(project.state != FundingState.Closed, "sorry anon, this project closed");
        require(msg.value > 0, "get your racks up anon");
        project.author.transfer(msg.value);
        project.funds += msg.value;
        projects[projectIndex] = project;
        //accede con llave que es el id y le pushea el struct al array que es el valor
        contributions[project.id].push(Contribution(msg.sender,msg.value));
        emit ProjectFunded(project.id, msg.value);
    }

    
    function changeProjectState(FundingState newState, uint projectIndex) public isAuthor(projectIndex){
        Project memory project = projects[projectIndex];
        require(newState != project.state, "the new state cannot be the current state anon");
        project.state = newState;
        emit ProjectStateChanged(project.id, newState);
    }

    //returns the project name.
    //param: Desired project index
    function getProjectName(uint projectIndex) public view returns (string memory) {
        require(projects.length > 1, "There are now projects to show");
        return projects[projectIndex].name;
    }

}