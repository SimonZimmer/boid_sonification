using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class flock_dyn : MonoBehaviour 
{
	public float speed = 0.001f;
	// turning speed of the boid
	float rotationSpeed = 10.0f;
	// boid rule: head towards the average heading of the whole group
	Vector3 averageHeading;
	// boid rule: head towards the average position of the whole group
	Vector3 averagePosition;
	// denseness of the flock
	float neighbourDistance = 5f;

	bool turning = false;

	public float speedMult = 1;

	// Use this for initialization
	void Start ()
	{
		speed = Random.Range(0.5f,1);
	}
	
	// Update is called once per frame
	void Update () 
	{
		// determine the bounding box of the manager cube

		if(Vector3.Distance(transform.position, Vector3.zero) >= globalFlock_dyn.limits)
		{
		 	turning = true;
		}
		else
		 	turning = false;

		if(turning)
		{
		  // inverse direction to current direction if going out of limits
			Vector3 direction = Vector3.zero - transform.position;
			// turn around
		 	transform.rotation = Quaternion.Slerp(transform.rotation,
		 																				Quaternion.LookRotation(direction),
		 																				rotationSpeed * Time.deltaTime);
		 	speed = Random.Range(0.5f,1);
		}	
		else
		{
		// apply the flock rules ("flocking intensity")
	  if (Random.Range(0,8) < 1)
			ApplyRules();
		}
		// move boids with speficied speed
		transform.Translate(0, 0, Time.deltaTime * speed * speedMult);
	}

	// flocking rules
	void ApplyRules()
	{
		Queue boids = new Queue();
		boids = globalFlock_dyn.allBoids;

		// center to the group
		Vector3 vcentre = Vector3.zero;
		// avoiding the crashing
		Vector3 vavoid = Vector3.zero;
		// group speed
		float gSpeed = 0.3f;

		Vector3 goalPos = globalFlock_dyn.goalPos;

		float dist;

		// number of objects who are within neighbour distance
		int groupSize = 0;
		foreach (GameObject boid in boids)
		{
			if(boid != this.gameObject && boid != null)
			{
				dist = Vector3.Distance(boid.transform.position, this.transform.position);
				if(dist <= neighbourDistance)
				{
					vcentre += boid.transform.position;
					groupSize++;

					// calculate vavoid as a vector which goes in another direction if distance is lower than 1.0f
					if(dist < 0.1f)
					{
						vavoid = vavoid + (this.transform.position - boid.transform.position);
					}

					flock_dyn anotherFlock = boid.GetComponent<flock_dyn>();
					//
					gSpeed = gSpeed + anotherFlock.speed;
				}
			}
		}

		if(groupSize > 0)
		{
			vcentre = vcentre/groupSize + (goalPos - this.transform.position);
			speed = gSpeed/groupSize * speedMult;

			Vector3 direction = (vcentre + vavoid) - transform.position;
			if(direction != Vector3.zero)
				transform.rotation = Quaternion.Slerp(transform.rotation, 
														 Quaternion.LookRotation(direction),
														 rotationSpeed * Time.deltaTime);
		}

		if(globalFlock_dyn.z > globalFlock_dyn.numBoids)
		{
			Debug.Log("DESTROY");
			Destroy(this.gameObject);
			globalFlock_dyn.z--;
		}
	}
}

// performance instrument?
// person tracken als hindernis