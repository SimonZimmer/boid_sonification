using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class globalFlock_dyn : MonoBehaviour 
{
	public GameObject boidPrefab;
	public GameObject goalPrefab;
	public static int z = 0;
	private float InstantiationTimer = 0.1f;

	public static int numBoids = 200;
	public static Vector3 goalPos = Vector3.zero;
	public static int limits = 20;

	public static Queue allBoids = new Queue();

	// public void BoidSpeed(float speedMult)
	// {
	// 	for(int i = 0; i < numBoids; i++)
	// 	{
	// 		allBoids[i].GetComponent<flock>().speedMult = speedMult;
	// 	}
	// }

	// Use this for initialization
	void Start ()
	{

	}

	// Update is called once per frame
	void Update () 
	{
		//instantiate boid at given rate and remove from queue if exceeding numBoids
		InstantiationTimer -= Time.deltaTime;
    if (InstantiationTimer <= 0)
    {
      if(z <= numBoids)
			{
				Vector3 pos = this.transform.position + new Vector3(Random.Range(-limits, limits),		  									         																		  Random.Range(-limits, limits),
																											    	Random.Range(-limits, limits));
				Debug.Log("INSTANTIATE");
				//send OSC
				OSCHandler.Instance.SendMessageToClient("SuperCollider", "/instantiate", 1);
				allBoids.Enqueue(Instantiate(boidPrefab, pos, Quaternion.identity));
		   	Debug.Log(z);
		   	z++;
		  }
			else
	    {
	    	Debug.Log("DESTROY");
	    	//send OSC
	    	OSCHandler.Instance.SendMessageToClient("SuperCollider", "/destroy", 1);
	     	allBoids.Dequeue();
	    }

	    //reset Instantiation Timer
      InstantiationTimer = 0.1f;
    }

    // update goalPos with coordinates of attractor
	  goalPos = goalPrefab.transform.position;		
	}
}